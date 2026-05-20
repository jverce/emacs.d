;;; 35-filetree.el --- Tree-layout file explorer (Treemacs) -*- lexical-binding: t -*-
;;; Commentary:
;; https://github.com/Alexander-Miller/treemacs
;;; Code:

(use-package treemacs
  :ensure t
  :bind (("M-0" . treemacs-select-window)
         ("s-b" . treemacs)
         ;; treemacs brings ace-window in as a dependency.
         ("M-o" . ace-window)))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(provide '35-filetree)
;;; 35-filetree.el ends here
