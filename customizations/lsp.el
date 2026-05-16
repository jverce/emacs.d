;;; -*- lexical-binding: t -*-
(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode)
  :init
  (setq flycheck-check-syntax-automatically '(save idle-change new-line mode-enabled)
        flycheck-idle-change-delay 0.3))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(defun my/lsp-ensure-features ()
  "Enable diagnostics and format-on-save for LSP-managed buffers."
  (lsp-diagnostics-mode 1)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . efs/lsp-mode-setup)
         (lsp-mode . my/lsp-ensure-features)
         (lsp-mode . company-mode))
  :commands (lsp lsp-mode lsp-deferred)
  :config
  (setq
   lsp-prefer-flymake nil
   lsp-enable-indentation t
   lsp-enable-on-type-formatting t
   lsp-rubocop-use-bundler t
   lsp-headerline-breadcrumb-icons-enable nil)
  (setq lsp-headerline-arrow nil)
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

(defun my/lsp-eslint-working-directory (orig-fn workspace current-file)
  "Use the nearest node_modules directory as ESLint's working directory.
Prevents ESLint from walking up to a parent .eslintrc whose plugins
aren't installed at that level."
  (let ((project-dir (locate-dominating-file current-file "node_modules")))
    (if project-dir
        (list :directory (directory-file-name (expand-file-name project-dir))
              :!cwd :json-false)
      (funcall orig-fn workspace current-file))))

(with-eval-after-load 'lsp-eslint
  (advice-add 'lsp-eslint--working-directory :around
              #'my/lsp-eslint-working-directory))

(define-key lsp-mode-map (kbd "M-<f7>") #'lsp-find-references)

(add-to-list 'major-mode-remap-alist
             '(go-mod . go-ts-mode))
