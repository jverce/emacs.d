;;; lang-markdown.el --- Markdown editing with markdownlint-cli2 -*- lexical-binding: t -*-
;;; Commentary:
;; markdown-mode for `.md', gfm-mode for README files, plus optional
;; format-on-save and flycheck linting via markdownlint-cli2. If the binary
;; is missing, both features quietly disable themselves (a one-time message
;; is printed) so the rest of the editor keeps working.
;;; Code:

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind (:map markdown-mode-map
              ("C-c C-c v" . markdown-live-preview-mode))
  :custom
  (markdown-indent-on-enter 'indent-and-new-item)
  (markdown-fontify-code-blocks-natively t))

(defvar my/markdown-missing-markdownlint-warning-shown nil)

(defun my/markdownlint-cli2-available-p ()
  (executable-find "markdownlint-cli2"))

(defun my/markdown-warn-if-markdownlint-missing ()
  (unless (or (my/markdownlint-cli2-available-p)
              my/markdown-missing-markdownlint-warning-shown)
    (setq my/markdown-missing-markdownlint-warning-shown t)
    (message "markdownlint-cli2 not found; Markdown linting and format-on-save are disabled.")))

(defun my/markdown-format-buffer ()
  "Apply `markdownlint-cli2 --fix' to the current buffer in place.
Runs silently from `before-save-hook'. No-op if the binary is missing."
  (when (and buffer-file-name
             (derived-mode-p 'markdown-mode)
             (my/markdownlint-cli2-available-p))
    (let ((tmpfile (make-temp-file "mdlfix-" nil ".md"))
          (point (point))
          (window-start (window-start)))
      (unwind-protect
          (progn
            (write-region nil nil tmpfile nil 'silent)
            ;; Ignore exit code: non-zero just means unfixable warnings remain;
            ;; the file has still been fixed in place where possible.
            (call-process "markdownlint-cli2" nil nil nil "--fix" tmpfile)
            (when (file-readable-p tmpfile)
              (erase-buffer)
              (insert-file-contents tmpfile)
              (goto-char (min point (point-max)))
              (set-window-start (selected-window) window-start)))
        (when (file-exists-p tmpfile)
          (ignore-errors (delete-file tmpfile)))))))

(defun my/markdown-install-save-hooks ()
  (add-hook 'before-save-hook #'my/markdown-format-buffer nil t))

(defun my/markdown-enable-flycheck ()
  (when (my/markdownlint-cli2-available-p)
    (flycheck-mode 1)
    (flycheck-select-checker 'markdown-markdownlint-cli2)))

(add-hook 'markdown-mode-hook #'my/markdown-warn-if-markdownlint-missing)
(add-hook 'markdown-mode-hook #'my/markdown-install-save-hooks)
(add-hook 'markdown-mode-hook #'my/markdown-enable-flycheck)

(provide 'lang-markdown)
;;; lang-markdown.el ends here
