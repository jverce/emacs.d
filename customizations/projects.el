;;; -*- lexical-binding: t -*-

;; Optional: ag is nice alternative to using grep with Projectile
(use-package ag
  :ensure t)

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
