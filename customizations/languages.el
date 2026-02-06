;;; languages.el --- Universal language support via tree-sitter + LSP -*- lexical-binding: t -*-

;; Start LSP for any programming mode.  lsp-deferred is a no-op when
;; no server is registered, so this is safe for modes like emacs-lisp.
(setq lsp-warn-no-matched-clients nil)
(add-hook 'prog-mode-hook #'lsp-deferred)

;; Extra auto-mode-alist entries for extensions not covered by treesit-auto.
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cts\\'" . typescript-ts-mode))
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
