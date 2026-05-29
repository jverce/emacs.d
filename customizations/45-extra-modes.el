;;; 45-extra-modes.el --- Universal LSP hook + extra mode mappings -*- lexical-binding: t -*-
;;; Commentary:
;; Wire `lsp-deferred' onto every prog-mode buffer except Python — Python's
;; LSP startup is gated on virtualenv resolution and is handled in
;; lang-python.el. Also map a handful of file types onto the right
;; tree-sitter modes when treesit-auto's defaults aren't enough.
;;; Code:

(setq lsp-warn-no-matched-clients t)

(defun my/lsp-deferred-except-python ()
  "Run `lsp-deferred' unless we are in a Python buffer."
  (unless (derived-mode-p 'python-base-mode)
    (lsp-deferred)))

(add-hook 'prog-mode-hook #'my/lsp-deferred-except-python)

;; Treat `.h' as C-or-C++ (treesit-auto only handles `.c' and `.cpp').
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-or-c++-ts-mode))

;; JVM build files.
(add-to-list 'auto-mode-alist '("\\.gradle\\'"     . groovy-mode))
(add-to-list 'auto-mode-alist '("\\.gradle\\.kts\\'" . kotlin-ts-mode))

(provide '45-extra-modes)
;;; 45-extra-modes.el ends here
