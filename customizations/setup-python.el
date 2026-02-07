;;; -*- lexical-binding: t -*-
;; Force Python buffers onto python-ts-mode when available.
(with-eval-after-load 'python
  (when (fboundp 'python-ts-mode)
    (setq major-mode-remap-alist
          (assq-delete-all 'python-mode major-mode-remap-alist))
    (add-to-list 'major-mode-remap-alist
                 '(python-mode . python-ts-mode))
    (add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
    (add-to-list 'interpreter-mode-alist '("python" . python-ts-mode))))

;; Install tree-sitter grammar if it's missing
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p)
           (not (treesit-language-available-p 'python)))
  (treesit-install-language-grammar 'python))

(use-package ruff-format
  :ensure t)

;; Ensure Python tools resolve from the project virtualenv first (uv uses .venv).
(defun my/python-project-venv-bin ()
  (when-let* ((project-root (or (locate-dominating-file default-directory ".venv")
                                (locate-dominating-file default-directory "pyproject.toml")))
              (venv-bin (expand-file-name ".venv/bin" project-root))
              ((file-directory-p venv-bin)))
    venv-bin))

(defun my/python-use-project-venv ()
  (when-let ((venv-bin (my/python-project-venv-bin)))
    (setq-local exec-path (cons venv-bin (delete venv-bin exec-path)))
    (setq-local process-environment (copy-sequence process-environment))
    ;; Restrict Python LSP client selection to our expected uv-managed tools.
    (setq-local lsp-enabled-clients '(pylsp ruff))
    (setenv
     "PATH"
     (mapconcat
      #'identity
      (cons venv-bin
            (delete venv-bin (split-string (or (getenv "PATH") "") path-separator t)))
      path-separator))))

;; Load Python LSP clients so lsp-deferred can match immediately.
(with-eval-after-load 'lsp-mode
  (require 'lsp-ruff nil t)
  (require 'lsp-pylsp nil t))

(defun my/python-after-envrc-apply (&rest _)
  "Re-apply Python venv PATH after envrc, then start LSP if needed."
  (when (derived-mode-p 'python-base-mode)
    (my/python-use-project-venv)
    (when (and (fboundp 'lsp-deferred)
               (not (bound-and-true-p lsp-mode)))
      (lsp-deferred))))

(with-eval-after-load 'envrc
  (unless (advice-member-p #'my/python-after-envrc-apply 'envrc--apply)
    (advice-add 'envrc--apply :after #'my/python-after-envrc-apply)))

;; IDE defaults for Python buffers, with a fallback to python-mode when needed.
(dolist (hook '(python-ts-mode-hook python-mode-hook))
  (add-hook hook #'my/python-use-project-venv)
  (add-hook hook #'ruff-format-on-save-mode)
  (add-hook hook #'lsp-deferred))
