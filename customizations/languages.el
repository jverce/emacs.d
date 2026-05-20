;;; languages.el --- Universal language support via tree-sitter + LSP -*- lexical-binding: t -*-

;; Start LSP for programming modes, but let Python manage startup after
;; virtualenv/envrc setup in setup-python.el.
(setq lsp-warn-no-matched-clients t)

(defun my/lsp-deferred-except-python ()
  (unless (derived-mode-p 'python-base-mode)
    (lsp-deferred)))

(add-hook 'prog-mode-hook #'my/lsp-deferred-except-python)

;; Extra auto-mode-alist entries for extensions not covered by treesit-auto.
(add-to-list 'auto-mode-alist '("Rakefile\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("Gemfile\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("Guardfile\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile\\'" . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-or-c++-ts-mode))

;; JVM build files
(add-to-list 'auto-mode-alist '("\\.gradle\\'" . groovy-mode))
(add-to-list 'auto-mode-alist '("\\.gradle\\.kts\\'" . kotlin-ts-mode))
