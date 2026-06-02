;;; 16-prose-checking.el --- Spelling and grammar checking -*- lexical-binding: t -*-
;;; Commentary:
;; Jinx provides fast local spell checking via Enchant.  Harper provides local
;; grammar/style diagnostics over LSP and checks comments only in supported
;; programming languages.
;;; Code:

(require 'seq)

(defvar my/jinx-missing-dictionary-warning-shown nil)

(defun my/jinx-dictionary-installer-command ()
  (abbreviate-file-name
   (expand-file-name "scripts/install-spell-dictionaries.sh" user-emacs-directory)))

(defun my/jinx-mode-if-dictionaries ()
  "Enable `jinx-mode' only when Enchant can load a dictionary.
Without dictionaries Jinx treats every word as misspelled, which makes prose
buffers unusable."
  (condition-case err
      (progn
        (jinx-mode 1)
        (unless (bound-and-true-p jinx--dicts)
          (jinx-mode -1)
          (unless my/jinx-missing-dictionary-warning-shown
            (setq my/jinx-missing-dictionary-warning-shown t)
            (message
             "Jinx disabled: no Enchant dictionaries for %s. Run %s."
             jinx-languages
             (my/jinx-dictionary-installer-command)))))
    (error
     (message "Jinx disabled: %s" (error-message-string err)))))

(use-package jinx
  :ensure t
  :hook ((text-mode prog-mode conf-mode git-commit-mode) . my/jinx-mode-if-dictionaries)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(defconst my/harper-language-id-by-mode
  '((text-mode . "plaintext")
    (markdown-mode . "markdown")
    (gfm-mode . "markdown")
    (org-mode . "org")
    (git-commit-mode . "gitcommit")
    (python-mode . "python")
    (python-ts-mode . "python")
    (js-mode . "javascript")
    (js-ts-mode . "javascript")
    (typescript-ts-mode . "typescript")
    (tsx-ts-mode . "typescriptreact")
    (go-mode . "go")
    (go-ts-mode . "go")
    (clojure-mode . "clojure")
    (clojurescript-mode . "clojure")
    (sh-mode . "shellscript")
    (bash-ts-mode . "shellscript")
    (ruby-mode . "ruby")
    (ruby-ts-mode . "ruby")
    (html-mode . "html")
    (nix-mode . "nix")
    (toml-ts-mode . "toml"))
  "Major modes and language identifiers supported by harper-ls.")

(defun my/harper-supported-mode-p ()
  (seq-some (lambda (entry) (derived-mode-p (car entry)))
            my/harper-language-id-by-mode))

(defun my/harper-language-id (_workspace)
  (or (seq-some (lambda (entry)
                  (when (derived-mode-p (car entry))
                    (cdr entry)))
                my/harper-language-id-by-mode)
      "plaintext"))

(defvar my/harper--server-path nil
  "Cached absolute path to a resolved harper-ls binary.")

(defun my/harper--candidate-paths ()
  "Candidate harper-ls binary paths, most-preferred first."
  (let* ((asdf-data (or (getenv "ASDF_DATA_DIR") (expand-file-name "~/.asdf")))
         (asdf-rust (sort (file-expand-wildcards
                           (expand-file-name "installs/rust/*/bin/harper-ls"
                                             asdf-data))
                          #'string>)))            ; newest rust version first
    (append
     ;; 1. Anything on exec-path: system, Homebrew, rustup, or an asdf reshim.
     (when-let ((p (executable-find "harper-ls"))) (list p))
     ;; 2. Native cargo/rustup install, even when ~/.cargo/bin isn't on PATH.
     (list (expand-file-name "~/.cargo/bin/harper-ls"))
     ;; 3. asdf-managed rust (cargo install without reshim).
     asdf-rust
     ;; 4. lsp-mode-managed cargo cache.
     (when (fboundp 'lsp-package-path)
       (list (lsp-package-path 'harper-ls))))))

(defun my/harper-locate-server ()
  "Locate an executable harper-ls across asdf, cargo, and system installs.
Return its absolute path, or nil when none is installed.  Memoizes the hit."
  (or my/harper--server-path
      (setq my/harper--server-path
            (seq-find (lambda (p) (and p (file-executable-p p)))
                      (my/harper--candidate-paths)))))

(defun my/harper-server-command ()
  "Return the harper-ls command, or nil when no binary is installed."
  (when-let ((bin (my/harper-locate-server)))
    (list bin "--stdio")))

(defun my/harper-start ()
  "Start harper-ls via lsp only when a binary is installed."
  (when (my/harper-locate-server)
    (lsp-deferred)))

(with-eval-after-load 'lsp-mode
  (lsp-dependency 'harper-ls
                  '(:system "harper-ls")
                  '(:cargo :package "harper-ls"
                           :path "harper-ls"))

  (lsp-register-custom-settings
   '(("harper-ls.linters.SpellCheck" nil t)
     ("harper-ls.linters.SentenceCapitalization" nil t)
     ("harper-ls.diagnosticSeverity" "hint")))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'my/harper-server-command)
    :activation-fn (lambda (_filename &optional _mode)
                     (my/harper-supported-mode-p))
    :language-id #'my/harper-language-id
    :add-on? t
    :priority -2
    :server-id 'harper-ls
    :download-server-fn (lambda (_client callback error-callback _update?)
                          (lsp-package-ensure 'harper-ls callback error-callback)))))

(dolist (hook '(text-mode-hook
                markdown-mode-hook
                gfm-mode-hook
                org-mode-hook
                git-commit-mode-hook))
  (add-hook hook #'my/harper-start))

(provide '16-prose-checking)
;;; 16-prose-checking.el ends here
