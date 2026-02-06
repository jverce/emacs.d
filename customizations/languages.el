;;; languages.el --- Universal language support via tree-sitter + LSP -*- lexical-binding: t -*-

;; Hook lsp-deferred into tree-sitter modes for languages that don't
;; have their own dedicated config files.
(dolist (hook '(rust-ts-mode-hook
               c-ts-mode-hook
               c++-ts-mode-hook
               java-ts-mode-hook
               ruby-ts-mode-hook
               kotlin-ts-mode-hook
               typescript-ts-mode-hook
               tsx-ts-mode-hook
               html-mode-hook
               css-ts-mode-hook
               json-ts-mode-hook
               bash-ts-mode-hook
               dockerfile-ts-mode-hook
               csharp-ts-mode-hook
               lua-ts-mode-hook
               nxml-mode-hook
               cmake-ts-mode-hook))
  (add-hook hook #'lsp-deferred))

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
