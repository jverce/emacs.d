;;; -*- lexical-binding: t -*-
;; projectile is another amazing package from the
;; creator of CIDER. It's got lots of commands
;; for searching and managing files in a project.
;; https://projectile.mx/
;; (setup (:package projectile)
;;   (projectile-mode +1)
;;   (:bind "s-p" projectile-command-map
;;          "C-c p" projectile-command-map))

;; counsel-projectile integrates projectile with
;; counsel's browse-and-select UI
;; (setup (:package counsel-projectile))

;; Optional: ag is nice alternative to using grep with Projectile
(use-package ag
  :ensure t)

;; Optional: Enable vertico as the selection framework to use with Projectile
(use-package vertico
  :ensure t
  :init
  (vertico-mode +1))

;; Optional: which-key will show you options for partially completed keybindings
;; It's extremely useful for packages with many keybindings like Projectile.
(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/dev/"))

  :config
  ;; On Linux, however, I usually go with another one
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

(use-package counsel-projectile
  :ensure t
  :config (counsel-projectile-mode))
