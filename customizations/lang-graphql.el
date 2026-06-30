;;; lang-graphql.el --- GraphQL editing with LSP -*- lexical-binding: t -*-
;;; Commentary:
;; graphql-mode for `.graphql' / `.gql' syntax + indentation, LSP via
;; lsp-mode's graphql client (npm i -g graphql-language-service-cli), and
;; format-on-save via Prettier (GraphQL is a built-in Prettier parser). The
;; LSP server has no formatting capability, so Prettier owns formatting; it
;; quietly disables itself when the binary is missing (a one-time message is
;; printed) so the rest of the editor keeps working.
;;; Code:

(use-package graphql-mode
  :ensure t)

(defvar my/graphql-missing-prettier-warning-shown nil)

(defun my/prettier-available-p ()
  (executable-find "prettier"))

(defun my/graphql-warn-if-prettier-missing ()
  (unless (or (my/prettier-available-p)
              my/graphql-missing-prettier-warning-shown)
    (setq my/graphql-missing-prettier-warning-shown t)
    (message "prettier not found; GraphQL format-on-save is disabled.")))

(defun my/graphql-format-buffer ()
  "Apply `prettier --write' to the current buffer in place.
Runs silently from `before-save-hook'. No-op if prettier is missing."
  (when (and buffer-file-name
             (derived-mode-p 'graphql-mode)
             (my/prettier-available-p))
    (let ((tmpfile (make-temp-file "gqlfmt-" nil ".graphql"))
          (point (point))
          (window-start (window-start)))
      (unwind-protect
          (progn
            (write-region nil nil tmpfile nil 'silent)
            ;; Ignore exit code: on a parse error prettier leaves the file
            ;; untouched, so reading it back is a harmless no-op.
            (call-process "prettier" nil nil nil "--write" tmpfile)
            (when (file-readable-p tmpfile)
              (erase-buffer)
              (insert-file-contents tmpfile)
              (goto-char (min point (point-max)))
              (set-window-start (selected-window) window-start)))
        (when (file-exists-p tmpfile)
          (ignore-errors (delete-file tmpfile)))))))

(my/define-language graphql
  :mode graphql-mode
  :extensions ("\\.graphql\\'" "\\.gql\\'")
  :lsp t
  :formatter my/graphql-format-buffer
  :extra-hooks (my/graphql-warn-if-prettier-missing))

(provide 'lang-graphql)
;;; lang-graphql.el ends here
