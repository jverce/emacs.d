;;; lang-js.el --- JavaScript / TypeScript / HTML / CoffeeScript -*- lexical-binding: t -*-
;;; Commentary:
;; js-ts-mode (and tsx-ts-mode / typescript-ts-mode for additional extensions),
;; per-project ESLint and Biome LSP gating, and tagedit for HTML structural
;; editing.
;;; Code:

(require 'cl-lib)

(use-package tagedit
  :ensure t
  :hook (html-mode . tagedit-mode))

(dolist (hook '(js-mode-hook
                js-ts-mode-hook
                html-mode-hook
                coffee-mode-hook))
  (add-hook hook #'subword-mode))

(setq js-indent-level 2)

;; CoffeeScript: highlight current indentation column and respect explicit
;; whitespace.
(with-eval-after-load 'coffee-mode
  (add-hook 'coffee-mode-hook #'highlight-indentation-current-column-mode)
  (setq coffee-tab-width 2
        coffee-cleanup-whitespace nil))

(use-package js-ts-mode
  :hook (js-ts-mode . lsp-deferred)
  :init
  (add-to-list 'auto-mode-alist '("\\.js\\'"  . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode)))

;; Additional TypeScript / JSX major-mode wiring for extensions that
;; treesit-auto doesn't cover.
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cts\\'" . typescript-ts-mode))

;; --- Per-project config detection -------------------------------------------

(defvar my/eslint-flat-config-files
  '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"
    "eslint.config.ts" "eslint.config.mts" "eslint.config.cts")
  "ESLint v9 flat-config filenames.")

(defvar my/eslint-legacy-config-files
  '(".eslintrc" ".eslintrc.js" ".eslintrc.cjs"
    ".eslintrc.json" ".eslintrc.yaml" ".eslintrc.yml")
  "ESLint legacy (eslintrc) config filenames.")

(defvar my/eslint-config-files
  (append my/eslint-flat-config-files my/eslint-legacy-config-files)
  "All ESLint config filenames we recognize, flat or legacy.")

(defvar my/biome-config-files
  '("biome.json" "biome.jsonc"))

(defun my/locate-config-upward (file filenames)
  "Return the nearest directory at or above FILE containing any of FILENAMES."
  (when file
    (locate-dominating-file
     file
     (lambda (dir)
       (seq-some (lambda (name) (file-exists-p (expand-file-name name dir)))
                 filenames)))))

(defun my/lsp-gate-web-clients ()
  "Disable eslint/biome LSP clients in buffers whose project lacks their config.
When a project uses ESLint v9 flat config (`eslint.config.*`), tell the LSP
client to opt into flat-config mode so the server doesn't walk up past the
project looking for legacy `.eslintrc' files."
  (when-let* ((file (buffer-file-name)))
    (let ((disabled (bound-and-true-p lsp-disabled-clients)))
      (unless (my/locate-config-upward file my/eslint-config-files)
        (push 'eslint disabled))
      (unless (my/locate-config-upward file my/biome-config-files)
        (push 'biome disabled))
      (when (my/locate-config-upward file my/biome-config-files)
        (push 'json-ls disabled))
      (setq-local lsp-disabled-clients disabled))
    ;; If the project uses flat config, force flat-config resolution two ways:
    ;;
    ;; 1. `lsp-eslint-experimental' tells the lsp-mode eslint client to send
    ;;    `experimental.useFlatConfig' during workspace init. Honored by
    ;;    lsp-mode's eslint client when it's recent enough.
    ;;
    ;; 2. `ESLINT_USE_FLAT_CONFIG=true' is read by ESLint itself when its
    ;;    Node.js process starts. This works regardless of which version of
    ;;    the LSP client is in use, and is what prevents the eslintrc resolver
    ;;    from walking past the project root looking for legacy `.eslintrc'
    ;;    files.
    (when (my/locate-config-upward file my/eslint-flat-config-files)
      (setq-local lsp-eslint-experimental
                  (cons '(useFlatConfig . t)
                        (assq-delete-all 'useFlatConfig
                                         (bound-and-true-p lsp-eslint-experimental))))
      (setq-local process-environment
                  (cons "ESLINT_USE_FLAT_CONFIG=true"
                        (seq-remove
                         (lambda (e)
                           (string-prefix-p "ESLINT_USE_FLAT_CONFIG=" e))
                         process-environment))))))

(add-hook 'prog-mode-hook #'my/lsp-gate-web-clients)

;; --- ESLint fix-on-save -----------------------------------------------------

(defun my/eslint-active-in-buffer-p ()
  "Return non-nil when the `eslint' LSP client is active in the current buffer."
  (and (bound-and-true-p lsp-mode)
       (fboundp 'lsp-workspaces)
       (cl-some (lambda (ws)
                  (eq (lsp--client-server-id (lsp--workspace-client ws))
                      'eslint))
                (lsp-workspaces))))

(defun my/eslint-fix-all-on-save ()
  "Run ESLint's `source.fixAll.eslint' code action.
No-op when ESLint isn't the active LSP server in this buffer."
  (when (my/eslint-active-in-buffer-p)
    ;; `lsp-execute-code-action-by-kind' raises when no matching action is
    ;; offered (e.g. clean file, or server still warming up). Saves shouldn't
    ;; fail because of that.
    (condition-case _err
        (lsp-execute-code-action-by-kind "source.fixAll.eslint")
      (error nil))))

(defun my/eslint-install-save-hook ()
  "Install ESLint fix-all on save buffer-locally."
  (add-hook 'before-save-hook #'my/eslint-fix-all-on-save nil t))

(dolist (hook '(js-mode-hook
                js-ts-mode-hook
                typescript-ts-mode-hook
                tsx-ts-mode-hook))
  (add-hook hook #'my/eslint-install-save-hook))

;; --- ESLint working-directory advice ----------------------------------------

(defun my/lsp-eslint-working-directory (orig-fn workspace current-file)
  "Use the nearest node_modules directory as ESLint's working directory.
Prevents ESLint from walking up to a parent .eslintrc whose plugins
aren't installed at that level."
  (let ((project-dir (locate-dominating-file current-file "node_modules")))
    (if project-dir
        (list :directory (directory-file-name (expand-file-name project-dir))
              :!cwd :json-false)
      (funcall orig-fn workspace current-file))))

(with-eval-after-load 'lsp-eslint
  (advice-add 'lsp-eslint--working-directory :around
              #'my/lsp-eslint-working-directory))

;; --- Biome LSP client -------------------------------------------------------

(defun my/biome-project-root (&optional file)
  "Return the project root for FILE — the nearest ancestor with a biome config."
  (let ((file (or file (buffer-file-name) default-directory)))
    (my/locate-config-upward file my/biome-config-files)))

(defun my/biome-server-command ()
  "Resolve the biome binary, preferring project-local node_modules."
  (let* ((file (or (buffer-file-name) default-directory))
         (project (locate-dominating-file file "node_modules"))
         (local (and project
                     (expand-file-name "node_modules/.bin/biome" project)))
         (bin (or (and local (file-executable-p local) local)
                  (executable-find "biome"))))
    (and bin (list bin "lsp-proxy"))))

(with-eval-after-load 'lsp-mode
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection
                     (lambda ()
                       (let ((default-directory
                              (or (my/biome-project-root) default-directory)))
                         (my/biome-server-command)))
                     (lambda () (and (my/biome-server-command) t)))
    :activation-fn (lambda (filename &optional _)
                     (string-match-p
                      (rx "." (or "js" "jsx" "mjs" "cjs"
                                  "ts" "tsx" "mts" "cts"
                                  "json" "jsonc" "css")
                          eos)
                      filename))
    :priority -1
    :server-id 'biome)))

(provide 'lang-js)
;;; lang-js.el ends here
