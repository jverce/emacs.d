;;; 25-projects.el --- Project navigation (Projectile) -*- lexical-binding: t -*-
;;; Commentary:
;; Projectile + counsel-projectile for project-aware file/buffer/grep
;; navigation. ag is kept available as an alternative to grep.
;;; Code:

(use-package ag
  :ensure t)

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/dev/"))
  :bind-keymap
  (("C-x p" . projectile-command-map)
   ("C-c p" . projectile-command-map))
  :config
  (dolist (dir '("node_modules" ".next" "dist" "build" "out"
                 ".turbo" ".cache" "coverage" ".venv" "venv"
                 "__pycache__" ".mypy_cache" ".pytest_cache"
                 "target" "vendor"))
    (add-to-list 'projectile-globally-ignored-directories dir))
  (dolist (suffix '(".min.js" ".min.css" ".map"))
    (add-to-list 'projectile-globally-ignored-file-suffixes suffix))
  (projectile-mode +1))

(use-package counsel-projectile
  :ensure t
  :after (counsel projectile)
  :config (counsel-projectile-mode))

(provide '25-projects)
;;; 25-projects.el ends here
