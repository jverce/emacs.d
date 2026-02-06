;;; -*- lexical-binding: t -*-
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . efs/lsp-mode-setup)
         (lsp-mode . company-mode)
         (python-ts-mode . lsp)
         )
  :commands (lsp lsp-mode lsp-deferred)
  :config
  (setq
   lsp-prefer-flymake nil
   lsp-enable-indentation t
   lsp-enable-on-type-formatting t
   lsp-format-buffer-on-save t)
  (lsp-modeline-code-actions-mode))

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
