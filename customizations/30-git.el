;;; 30-git.el --- Git integration via Magit -*- lexical-binding: t -*-
;;; Commentary:
;; magit is a full-fledged interface for git.
;; https://magit.vc/manual/magit/
;;
;; Loaded eagerly (`:demand t') so that requiring `magit' pulls in
;; `git-commit', whose `global-git-commit-mode' adds the `find-file-hook'
;; that turns `.git/COMMIT_EDITMSG' into a proper commit buffer when git
;; opens it through `emacsclient'. Lazy-loading magit would skip this
;; setup and leave terminal `git commit' in plain `text-mode'.
;;; Code:

(add-to-list 'package-pinned-packages '(magit . "melpa-stable") t)

(use-package magit
  :ensure t
  :demand t
  :bind ("C-M-;" . magit-status))

(provide '30-git)
;;; 30-git.el ends here
