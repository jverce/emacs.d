;; treemacs is a tree layout file explorer
;; https://github.com/Alexander-Miller/treemacs
(use-package treemacs
  :ensure t)
(use-package treemacs-projectile
  :ensure t)
(use-package treemacs-magit
  :ensure t)
(setup (:package treemacs treemacs-projectile treemacs-magit)
  (:global "M-0" treemacs-select-window
           "M-o" ace-window ;; treemacs brings ace-window as a dependency
           "s-b" treemacs))
