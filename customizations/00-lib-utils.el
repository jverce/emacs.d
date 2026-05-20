;;; 00-lib-utils.el --- Shared helpers for the rest of the config -*- lexical-binding: t -*-
;;; Commentary:
;; Tiny utility functions used by multiple modules. Loaded before any other
;; customization file so language modules can rely on them.
;;; Code:

(require 'seq)

(defun my/locate-config-upward (file filenames)
  "Return the nearest directory at or above FILE containing any of FILENAMES.
Returns nil when nothing is found."
  (when file
    (locate-dominating-file
     file
     (lambda (dir)
       (seq-some (lambda (name) (file-exists-p (expand-file-name name dir)))
                 filenames)))))

(defun my/find-executable-in-project (name)
  "Resolve executable NAME, preferring node_modules/.bin under FILE's project.
Falls back to `executable-find'. Returns the absolute path or nil."
  (let* ((file (or (buffer-file-name) default-directory))
         (project (locate-dominating-file file "node_modules"))
         (local (and project
                     (expand-file-name
                      (concat "node_modules/.bin/" name) project))))
    (or (and local (file-executable-p local) local)
        (executable-find name))))

(provide '00-lib-utils)
;;; 00-lib-utils.el ends here
