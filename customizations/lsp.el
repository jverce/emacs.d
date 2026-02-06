;;; -*- lexical-binding: t -*-
(use-package flycheck
  :ensure t)

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(defun my/lsp-ensure-features ()
  "Enable flycheck, diagnostics, and format-on-save after LSP connects.
`lsp-managed-mode' should handle this but sometimes fails to activate;
this hook on `lsp-after-open-hook' provides a reliable fallback."
  (flycheck-mode 1)
  (lsp-diagnostics-mode 1)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . efs/lsp-mode-setup)
         (lsp-mode . company-mode))
  :commands (lsp lsp-mode lsp-deferred)
  :config
  (setq
   lsp-prefer-flymake nil
   lsp-enable-indentation t
   lsp-enable-on-type-formatting t)
  (lsp-modeline-code-actions-mode)
  (add-hook 'lsp-after-open-hook #'my/lsp-ensure-features))

(setq lsp-ui-sideline-enable nil)
(setq lsp-ui-sideline-show-hover nil)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode
  :ensure t)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(define-key lsp-mode-map (kbd "M-<f7>") #'lsp-find-references)

(setq major-mode-remap-alist
      '((go-mod . go-ts-mode)))
