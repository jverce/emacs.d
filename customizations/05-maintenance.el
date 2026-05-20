;;; 05-maintenance.el --- Config-maintenance commands -*- lexical-binding: t -*-
;;; Commentary:
;; Interactive commands for keeping this Emacs configuration up to date.
;; Add more `my/upgrade-*' / `my/clean-*' commands here over time.
;;; Code:

(defun my/upgrade-config ()
  "Upgrade this Emacs configuration end-to-end.

Performs the following steps:
  1. Refresh ELPA archives and upgrade all installed packages
     (delegates to `package-upgrade-all', which prompts for confirmation
     and reports `No packages to upgrade' when there's nothing to do).
  2. Pull the latest commits on every git submodule under this repo
     (currently just the GitHub Dark Dimmed theme), after a y/n prompt.

After this finishes, restart Emacs to load any new package versions."
  (interactive)
  (unless (fboundp 'package-upgrade-all)
    (user-error "`package-upgrade-all' requires Emacs 29 or later"))

  ;; 1. ELPA packages.
  (message "[1/2] Refreshing ELPA archives and upgrading packages...")
  (package-upgrade-all t)

  ;; 2. Git submodules.
  (let* ((default-directory user-emacs-directory)
         (gitmodules (expand-file-name ".gitmodules" user-emacs-directory)))
    (cond
     ((not (file-exists-p gitmodules))
      (message "[2/2] No .gitmodules; skipping submodule update."))
     ((not (executable-find "git"))
      (message "[2/2] git not on PATH; skipping submodule update."))
     ((not (yes-or-no-p "Pull latest commits on git submodules? "))
      (message "[2/2] Skipped submodule update."))
     (t
      (message "[2/2] Updating git submodules...")
      (with-temp-buffer
        (let ((exit (call-process
                     "git" nil t nil
                     "submodule" "update" "--init" "--remote" "--merge")))
          (if (zerop exit)
              (let ((out (string-trim (buffer-string))))
                (if (string-empty-p out)
                    (message "Submodules already up to date.")
                  (message "Submodules updated:\n%s" out)))
            (message "Submodule update failed (exit %d):\n%s"
                     exit (string-trim (buffer-string)))))))))

  (message "Config upgrade complete. Restart Emacs to pick up new package versions."))

(provide '05-maintenance)
;;; 05-maintenance.el ends here
