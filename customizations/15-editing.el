;;; 15-editing.el --- General editing behavior -*- lexical-binding: t -*-
;;; Commentary:
;; Buffer-level editing defaults: indentation, line numbers, save-place,
;; backups, completion, comments, and tree-sitter grammar management.
;;; Code:

;; hippie-expand for text autocompletion.
;; http://www.emacswiki.org/emacs/HippieExpand
(global-set-key (kbd "M-/") #'hippie-expand)

;; Lisp-friendly hippie-expand.
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;; Scroll while keeping the cursor on the same screen line.
(keymap-global-set "M-n" #'scroll-up-line)
(keymap-global-set "M-p" #'scroll-down-line)

;; Highlight matching parens.
(show-paren-mode 1)

;; Highlight the current line.
(global-hl-line-mode 1)

;; Line numbers everywhere except where they get in the way.
(global-display-line-numbers-mode 1)
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; No hard tabs; shell scripts indent by 2.
(setq-default indent-tabs-mode nil
              sh-basic-offset 2
              sh-indentation 2)

;; Restore point to its previous position when re-visiting a file.
;; http://www.emacswiki.org/emacs/SavePlace
(save-place-mode 1)
(setq save-place-file (concat user-emacs-directory "places"))

;; Send all backups to ~/.emacs.d/backups; turn off auto-save files.
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      auto-save-default nil)

;; Strip trailing whitespace on save.
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Comments: C-/ toggles comments via evil-nerd-commenter; C-M-/ is undo-redo.
(global-set-key (kbd "C-M-/") #'undo-redo)
(use-package evil-nerd-commenter
  :ensure t
  :bind ("C-/" . evilnc-comment-or-uncomment-lines))

(setq electric-indent-mode t)

(use-package company
  :ensure t
  :hook (after-init . global-company-mode))

;; treesit-auto manages tree-sitter grammars and remaps modes automatically.
(use-package treesit-auto
  :ensure t
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (delete 'yaml treesit-auto-langs)
  (global-treesit-auto-mode))

;; Grammar sources for languages where the default `treesit-auto' source needs
;; pinning or doesn't exist.
(setq treesit-language-source-alist
      '((go         "https://github.com/tree-sitter/tree-sitter-go" "v0.20.0")
        (gomod      "https://github.com/camdencheek/tree-sitter-go-mod")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")))

(provide '15-editing)
;;; 15-editing.el ends here
