;;; lang-ruby.el --- Ruby editing with rubocop-ls / ruby-lsp / solargraph -*- lexical-binding: t -*-
;;; Commentary:
;; ruby-ts-mode wiring and per-project gating for the three Ruby LSP clients
;; lsp-mode ships (rubocop-ls, ruby-lsp-ls, ruby-ls aka solargraph).
;;
;; The hard problem this module solves: lsp-mode launches the language
;; server process from the workspace root it picks (typically the `.git'
;; directory), not the buffer's directory. In a monorepo whose Gemfile
;; lives in a subdirectory (e.g. `repo/.git' + `repo/api/Gemfile'),
;; `bundle exec' is spawned at the repo root, walks up looking for a
;; Gemfile, finds nothing, and dies with
;;
;;   Could not locate Gemfile or .bundle/ directory
;;
;; before the rubocop / ruby-lsp / solargraph server even starts. The
;; bundler-native fix is to set `BUNDLE_GEMFILE' to the absolute path of
;; the Gemfile we found, which makes `bundle exec' resolve the right
;; project regardless of CWD. We do that via lsp-mode's `:environment-fn'.
;;
;; We also gate per buffer: a Bundler-mode client only starts when its gem
;; is in the project's `Gemfile.lock' (so we don't spawn solargraph in a
;; project that doesn't depend on it). When there's no Gemfile, we fall
;; back to the system binary on PATH; if that's missing too, we add the
;; client to buffer-local `lsp-disabled-clients' so there's no noisy
;; `*…::stderr*' buffer.
;;; Code:

(require 'cl-lib)

(defvar my/ruby-bundler-config-files '("Gemfile" "gems.rb")
  "Filenames that mark the root of a Bundler project.")

;; Ruby ecosystem files that ruby-ts-mode doesn't catch by default.
(dolist (entry '(("Rakefile\\'"   . ruby-ts-mode)
                 ("\\.rake\\'"    . ruby-ts-mode)
                 ("Gemfile\\'"    . ruby-ts-mode)
                 ("\\.gemspec\\'" . ruby-ts-mode)
                 ("\\.ru\\'"      . ruby-ts-mode)
                 ("Guardfile\\'"  . ruby-ts-mode)
                 ("Vagrantfile\\'". ruby-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(defun my/ruby-bundler-root (&optional file)
  "Return the nearest ancestor of FILE containing a Gemfile or gems.rb."
  (let ((file (or file (buffer-file-name) default-directory)))
    (my/locate-config-upward file my/ruby-bundler-config-files)))

(defun my/ruby-bundler-gemfile (&optional file)
  "Return the absolute Gemfile (or gems.rb) path above FILE, or nil."
  (when-let* ((root (my/ruby-bundler-root file)))
    (cl-some (lambda (name)
               (let ((path (expand-file-name name root)))
                 (and (file-exists-p path) path)))
             my/ruby-bundler-config-files)))

(defun my/ruby-gem-in-lockfile-p (gem &optional gemfile)
  "Return non-nil if GEM appears as a top-level entry in GEMFILE's lockfile.
GEMFILE defaults to the result of `my/ruby-bundler-gemfile'."
  (when-let* ((gemfile (or gemfile (my/ruby-bundler-gemfile)))
              (lock (concat gemfile ".lock"))
              ((file-readable-p lock)))
    (with-temp-buffer
      (insert-file-contents lock)
      (goto-char (point-min))
      ;; A locked gem appears as `    NAME (X.Y.Z)' (4 spaces, then name,
      ;; then version in parens). Dependency lines use 6 spaces, so this
      ;; regex only matches the actual lockfile entries.
      (re-search-forward (format "^    %s (" (regexp-quote gem)) nil t))))

(defun my/ruby--server-runnable-p (binary use-bundler)
  "Return non-nil when BINARY can be launched, optionally via Bundler."
  (or (and use-bundler (executable-find "bundle"))
      (executable-find binary)))

(defun my/ruby-configure-lsp ()
  "Per-buffer rubocop-ls / ruby-lsp / solargraph gating.
Bundler is only enabled for a given client when the gem is present in
this project's Gemfile.lock. Clients whose server cannot be launched at
all are added to buffer-local `lsp-disabled-clients' so they never spawn."
  (let* ((file (buffer-file-name))
         (gemfile (and file (my/ruby-bundler-gemfile file)))
         (disabled (bound-and-true-p lsp-disabled-clients)))
    (cl-flet ((bundled-p (gem)
                (and gemfile (my/ruby-gem-in-lockfile-p gem gemfile) t)))
      (let ((rubocop-bundled (bundled-p "rubocop"))
            (ruby-lsp-bundled (bundled-p "ruby-lsp"))
            (solargraph-bundled (bundled-p "solargraph")))
        (setq-local lsp-rubocop-use-bundler    rubocop-bundled)
        (setq-local lsp-ruby-lsp-use-bundler   ruby-lsp-bundled)
        (setq-local lsp-solargraph-use-bundler solargraph-bundled)
        (dolist (entry `((rubocop-ls  "rubocop"    ,rubocop-bundled)
                         (ruby-lsp-ls "ruby-lsp"   ,ruby-lsp-bundled)
                         (ruby-ls     "solargraph" ,solargraph-bundled)))
          (cl-destructuring-bind (server-id binary use-bundler) entry
            (unless (my/ruby--server-runnable-p binary use-bundler)
              (cl-pushnew server-id disabled))))))
    (setq-local lsp-disabled-clients disabled)))

(dolist (hook '(ruby-ts-mode-hook ruby-mode-hook))
  (add-hook hook #'my/ruby-configure-lsp))

;; Re-register each Ruby client so `bundle exec' resolves the right project
;; even when lsp-mode launches the process from the workspace root rather
;; than the Gemfile's directory. We do this by exporting BUNDLE_GEMFILE in
;; the spawned process environment via lsp-mode's `:environment-fn'.
;;
;; The :environment-fn closure is invoked at connect time and reads the
;; current buffer's Gemfile via `my/ruby-bundler-gemfile', so it picks up
;; the right path for whichever Ruby buffer triggered the LSP startup.
(defun my/ruby--bundle-gemfile-env-fn ()
  "Environment alist exporting BUNDLE_GEMFILE for the current buffer."
  (when-let ((gemfile (my/ruby-bundler-gemfile)))
    `(("BUNDLE_GEMFILE" . ,gemfile))))

(with-eval-after-load 'lsp-rubocop
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'lsp-rubocop--build-command)
    :activation-fn (lsp-activate-on "ruby")
    :environment-fn #'my/ruby--bundle-gemfile-env-fn
    :priority -1
    :server-id 'rubocop-ls)))

(with-eval-after-load 'lsp-ruby-lsp
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'lsp-ruby-lsp--build-command)
    :activation-fn (lsp-activate-on "ruby")
    :environment-fn #'my/ruby--bundle-gemfile-env-fn
    :library-folders-fn (lambda (_ws) lsp-ruby-lsp-library-directories)
    :priority -2
    :action-handlers (ht ("rubyLsp.openFile" #'lsp-ruby-lsp--open-file)
                         ("rubyLsp.runTest" #'lsp-ruby-lsp--run-test)
                         ("rubyLsp.runTestInTerminal" #'lsp-ruby-lsp--run-test))
    :server-id 'ruby-lsp-ls)))

(with-eval-after-load 'lsp-solargraph
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'lsp-solargraph--build-command)
    :activation-fn (lsp-activate-on "ruby")
    :environment-fn #'my/ruby--bundle-gemfile-env-fn
    :priority -1
    :multi-root lsp-solargraph-multi-root
    :library-folders-fn (lambda (_ws) lsp-solargraph-library-directories)
    :server-id 'ruby-ls
    :initialized-fn (lambda (workspace)
                      (with-lsp-workspace workspace
                        (lsp--set-configuration
                         (lsp-configuration-section "solargraph")))))))

(provide 'lang-ruby)
;;; lang-ruby.el ends here
