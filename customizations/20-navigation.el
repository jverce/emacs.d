;;; 20-navigation.el --- Minibuffer completion and discoverability -*- lexical-binding: t -*-
;;; Commentary:
;; which-key shows the next-key menu after a prefix.
;; ivy + counsel + swiper provide minibuffer completion and search.
;;; Code:

(use-package which-key
  :ensure t
  :custom (which-key-idle-delay 0.3)
  :config (which-key-mode))

(use-package counsel
  :ensure t
  :demand t
  :bind (("C-s"     . swiper)
         ("s-f"     . swiper)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-b" . counsel-switch-buffer)
         ("M-x"     . counsel-M-x))
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (ivy-count-format "%d/%d ")
  :config
  (ivy-mode))

;; ivy-rich adds docstrings and additional metadata in the ivy minibuffer.
;; https://github.com/Yevgnen/ivy-rich
(use-package ivy-rich
  :ensure t
  :after counsel
  :config (ivy-rich-mode))

(provide '20-navigation)
;;; 20-navigation.el ends here
