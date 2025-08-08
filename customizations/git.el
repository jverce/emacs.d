;; magit is a full-fledged interface for git
;; https://magit.vc/manual/magit/
(add-to-list 'package-pinned-packages '(magit . "melpa-stable") t)
(use-package magit
  :ensure t)
(setup (:package magit)
  (:global "C-M-;" magit-status))
