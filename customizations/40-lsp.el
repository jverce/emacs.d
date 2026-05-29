;;; 40-lsp.el --- LSP, flycheck, and dap-mode core wiring -*- lexical-binding: t -*-
;;; Commentary:
;; lsp-mode is the universal LSP client. flycheck handles diagnostics where
;; LSP doesn't. dap-mode provides a debugger UI. Per-language clients are
;; loaded by their respective `lang-*' / `setup-*' files.
;;; Code:

(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode)
  :init
  (setq flycheck-check-syntax-automatically
        '(save idle-change new-line mode-enabled)
        flycheck-idle-change-delay 0.3))

(defun my/lsp-setup-headerline ()
  "Show project-relative path / filename / symbols in the LSP headerline."
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(defun my/lsp-ensure-features ()
  "Enable diagnostics and format-on-save for LSP-managed buffers."
  (lsp-diagnostics-mode 1)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-mode lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . my/lsp-setup-headerline)
         (lsp-mode . my/lsp-ensure-features)
         (lsp-mode . company-mode))
  :bind (:map lsp-mode-map
              ("M-<f7>" . lsp-find-references))
  :custom
  (lsp-prefer-flymake nil)
  (lsp-enable-indentation t)
  (lsp-enable-on-type-formatting t)
  (lsp-headerline-breadcrumb-icons-enable nil)
  (lsp-headerline-arrow nil)
  :config
  (lsp-modeline-code-actions-mode))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-show-hover nil))

(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list)

(use-package dap-mode
  :ensure t)

(provide '40-lsp)
;;; 40-lsp.el ends here
