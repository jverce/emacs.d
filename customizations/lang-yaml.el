;;; lang-yaml.el --- YAML editing with LSP -*- lexical-binding: t -*-
;;; Commentary:
;; yaml-mode plus lsp-deferred for `.yml' / `.yaml' files.
;; YAML is intentionally excluded from `treesit-auto-langs' in editing.el
;; because the upstream tree-sitter grammar isn't yet a good fit.
;;; Code:

(use-package yaml-mode
  :ensure t)

(my/define-language yaml
  :mode yaml-mode
  :extensions ("\\.ya?ml\\'")
  :lsp t)

(provide 'lang-yaml)
;;; lang-yaml.el ends here
