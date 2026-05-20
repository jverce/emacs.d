;;; lang-go.el --- Go editing with gopls -*- lexical-binding: t -*-
;;; Commentary:
;; go-ts-mode for `.go' files, go-mod-ts-mode for go.mod, format and organize
;; imports on save via gopls. No other gofmt/goimports save hooks should be
;; enabled globally.
;;; Code:

(my/define-language go
  :mode go-ts-mode
  :extensions ("\\.go\\'")
  :lsp t
  :save-hooks (lsp-format-buffer lsp-organize-imports))

(my/define-language go-mod
  :mode go-mod-ts-mode
  :extensions ("/go\\.mod\\'")
  :lsp t)

(provide 'lang-go)
;;; lang-go.el ends here
