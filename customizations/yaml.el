(use-package yaml-mode
  :ensure t

  :hook
  (yaml-mode . lsp-deferred)

  :init
  (add-to-list
   'auto-mode-alist
   '("\\.yaml\\'" . yaml-mode))
  (add-to-list
   'auto-mode-alist
   '("\\.yml\\'" . yaml-mode))
  )
