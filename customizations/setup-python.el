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
    ;; Use pylsp as the Python LSP backend.
    (setq-local lsp-enabled-clients '(pylsp))
    (setenv
     "PATH"
     (mapconcat
      #'identity
      (cons venv-bin
            (delete venv-bin (split-string (or (getenv "PATH") "") path-separator t)))
      path-separator))))

;; Load Python LSP clients so lsp-deferred can match immediately.
(with-eval-after-load 'lsp-mode
  (require 'lsp-pylsp nil t))

(defun my/python-lsp-server-available-p ()
  (executable-find "pylsp"))

(defun my/python-start-lsp-if-available ()
  (when (and (fboundp 'lsp-deferred)
             (my/python-lsp-server-available-p)
             (not (bound-and-true-p lsp-mode)))
    (lsp-deferred)))

(defun my/python-after-envrc-apply (&rest _)
  "Re-apply Python venv PATH after envrc, then start LSP if needed."
  (when (derived-mode-p 'python-base-mode)
    (my/python-use-project-venv)
    (my/python-start-lsp-if-available)))

(with-eval-after-load 'envrc
  (unless (advice-member-p #'my/python-after-envrc-apply 'envrc--apply)
    (advice-add 'envrc--apply :after #'my/python-after-envrc-apply)))

(defun my/python-lsp-process-p (proc)
  (let* ((name (process-name proc))
         (cmd (ignore-errors (process-command proc)))
         (cmdline (if (listp cmd) (mapconcat #'identity cmd " ") "")))
    (or (string-match-p "pylsp" name)
        (string-match-p "pylsp" cmdline))))

(defun my/python-stop-pylsp-processes-on-exit ()
  "Terminate pylsp-related subprocesses before daemon shutdown."
  (dolist (proc (process-list))
    (when (my/python-lsp-process-p proc)
      (set-process-query-on-exit-flag proc nil)
      (ignore-errors (delete-process proc))))
  ;; Give process teardown a short moment to complete before exiting.
  (accept-process-output nil 0.05))

;; Run early in kill-emacs-hook to avoid pylsp-related stop hangs.
(add-hook 'kill-emacs-hook #'my/python-stop-pylsp-processes-on-exit)

;; IDE defaults for Python buffers, with a fallback to python-mode when needed.
(dolist (hook '(python-ts-mode-hook python-mode-hook))
  (add-hook hook #'my/python-use-project-venv)
  (add-hook hook #'ruff-format-on-save-mode)
  (add-hook hook #'my/python-start-lsp-if-available))
