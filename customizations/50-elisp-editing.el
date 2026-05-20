;;; 50-elisp-editing.el --- Lisp editing helpers -*- lexical-binding: t -*-
;;; Commentary:
;; paredit for structural Lisp editing, eldoc for inline docs,
;; rainbow-delimiters for nested-pair color cues.
;;; Code:

(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode
          eval-expression-minibuffer-setup
          ielm-mode
          lisp-mode
          lisp-interaction-mode
          scheme-mode)
         . enable-paredit-mode))

(add-hook 'emacs-lisp-mode-hook       #'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook #'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook             #'turn-on-eldoc-mode)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(provide '50-elisp-editing)
;;; 50-elisp-editing.el ends here
