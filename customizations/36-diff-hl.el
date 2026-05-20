;;; 36-diff-hl.el --- VCS gutter indicators (diff-hl) -*- lexical-binding: t -*-
;;; Commentary:
;; Show added / changed / deleted lines in the fringe for any VCS-tracked
;; buffer (git or otherwise — diff-hl rides on Emacs's built-in `vc').
;;
;; - `global-diff-hl-mode' enables indicators everywhere.
;; - `diff-hl-flydiff-mode' updates them as you type, before you save —
;;   matching VS Code's live behaviour.
;; - The magit hooks make the gutters refresh after commits, stashes,
;;   rebases, etc. without needing to revert the buffer.
;; - In terminal frames (`emacsclient -t'), there is no fringe, so we fall
;;   back to the margin via `diff-hl-margin-mode'. With the daemon we may
;;   not know yet whether the next frame is graphical, so we re-evaluate
;;   on every new frame.
;;; Code:

(defun my/diff-hl-toggle-margin-for-frame (&optional frame)
  "Enable `diff-hl-margin-mode' iff FRAME is a terminal frame.
The fringe is only available in graphical frames; in terminals we render
indicators in the margin instead."
  (when (featurep 'diff-hl-margin)
    (with-selected-frame (or frame (selected-frame))
      (if (display-graphic-p)
          (when (bound-and-true-p diff-hl-margin-mode)
            (diff-hl-margin-mode -1))
        (unless (bound-and-true-p diff-hl-margin-mode)
          (diff-hl-margin-mode 1))))))

(use-package diff-hl
  :ensure t
  ;; Eager activation after startup: gutters appear in any file buffer as
  ;; soon as it's visited, without waiting for a magit refresh or dired
  ;; visit to load the package.
  :hook ((after-init         . global-diff-hl-mode)
         (after-init         . diff-hl-flydiff-mode)
         (dired-mode         . diff-hl-dired-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  ;; `diff-hl-margin-mode' lives in a separate file inside the package and
  ;; isn't autoloaded — pull it in explicitly so the toggle helper can use it.
  (require 'diff-hl-margin)
  (add-hook 'after-make-frame-functions
            #'my/diff-hl-toggle-margin-for-frame)
  ;; Apply once for the initial frame (the non-daemon case).
  (my/diff-hl-toggle-margin-for-frame))

(provide '36-diff-hl)
;;; 36-diff-hl.el ends here
