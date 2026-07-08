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

(defun my/lsp-format-buffer-maybe ()
  "Format via LSP only when the server advertises the capability.
Some servers (e.g. graphql-language-service) have no formatting support;
calling `lsp-format-buffer' there errors and aborts the save."
  (when (lsp-feature? "textDocument/formatting")
    (lsp-format-buffer)))

(defun my/lsp-ensure-features ()
  "Enable diagnostics and format-on-save for LSP-managed buffers."
  (lsp-diagnostics-mode 1)
  (add-hook 'before-save-hook #'my/lsp-format-buffer-maybe nil t))

(defun my/makefile-capf ()
  "`makefile-completions-at-point' with target/macro tables refreshed first.
make-mode only refreshes them from electric keys (off by default), and
falls through to LSP when the buffer has no match."
  (let ((inhibit-message t))
    ;; ponytail: full-buffer rescan per completion request; cache if it lags.
    (makefile-pickup-everything t))
  (nconc (makefile-completions-at-point) (list :exclusive 'no)))

(defun my/makefile-prefer-native-completion ()
  "Complete this buffer's targets/macros before autotools-ls.
The server only knows builtin make names, not buffer-defined ones."
  (when (derived-mode-p 'makefile-mode)
    (add-hook 'completion-at-point-functions #'my/makefile-capf nil t)))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-mode lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . my/lsp-setup-headerline)
         (lsp-mode . my/lsp-ensure-features)
         (lsp-mode . company-mode)
         (lsp-completion-mode . my/makefile-prefer-native-completion))
  :bind (:map lsp-mode-map
              ("M-<f7>" . lsp-find-references))
  :custom
  (lsp-prefer-flymake nil)
  (lsp-enable-indentation t)
  (lsp-enable-on-type-formatting t)
  (lsp-headerline-breadcrumb-icons-enable nil)
  (lsp-headerline-arrow nil)
  :config
  (lsp-modeline-code-actions-mode)
  ;; lsp-mode registers autotools-ls for makefile modes (lsp-autotools.el)
  ;; but ships no languageId mapping for them.
  (dolist (mode '(makefile-mode makefile-automake-mode makefile-gmake-mode
                  makefile-makepp-mode makefile-bsdmake-mode makefile-imake-mode))
    (add-to-list 'lsp-language-id-configuration (cons mode "makefile"))))

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
