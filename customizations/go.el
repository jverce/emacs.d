(use-package go-ts-mode
  :hook
  (go-ts-mode . lsp-deferred)

  :init
  (add-to-list
   'auto-mode-alist
   '("\\.go\\'" . go-ts-mode))
  (add-to-list
   'auto-mode-alist
   '("/go\\.mod\\'" . go-mod-ts-mode))
  )

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-ts-mode-hook #'lsp-go-install-save-hooks)
