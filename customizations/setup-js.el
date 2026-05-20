;;; -*- lexical-binding: t -*-
;; javascript / html
(use-package tagedit
  :ensure t)
(setup (:package tagedit)
  (:hook-into html-mode))

(setup subword-mode
  (:hook-into js-mode
	      html-mode
	      coffee-mode))

(setq js-indent-level 2)

;; coffeescript
(setup coffee-mode
  (:hook highlight-indentation-current-column-mode
	 (defun coffee-mode-newline-and-indent ()
	   (define-key coffee-mode-map "\C-j" 'coffee-newline-and-indent)
	   (setq coffee-cleanup-whitespace nil))))

(setq coffee-tab-width 2)

(use-package js-ts-mode
  :hook
  (js-ts-mode . lsp-deferred)

  :init
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode)))

;; Additional TypeScript / JSX major-mode wiring.
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cts\\'" . typescript-ts-mode))

;; --- Per-project config detection -------------------------------------------

(defvar my/eslint-config-files
  '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"
    "eslint.config.ts" "eslint.config.mts" "eslint.config.cts"
    ".eslintrc" ".eslintrc.js" ".eslintrc.cjs"
    ".eslintrc.json" ".eslintrc.yaml" ".eslintrc.yml"))

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
  "Disable eslint/biome LSP clients in buffers whose project lacks their config."
  (when-let* ((file (buffer-file-name)))
    (let ((disabled (bound-and-true-p lsp-disabled-clients)))
      (unless (my/locate-config-upward file my/eslint-config-files)
        (push 'eslint disabled))
      (unless (my/locate-config-upward file my/biome-config-files)
        (push 'biome disabled))
      (setq-local lsp-disabled-clients disabled))))

(add-hook 'prog-mode-hook #'my/lsp-gate-web-clients)

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
