;; paredit enables structural editing of just about any lisp
;; https://www.emacswiki.org/emacs/ParEdit
(use-package paredit
  :ensure t)
(setup (:package paredit)
  (:hook-into emacs-lisp-mode
	      eval-expression-minibuffer-setup
	      ielm-mode
	      lisp-mode
	      lisp-interaction-mode
	      scheme-mode))

(setup turn-on-eldoc-mode
  (:hook-into emacs-lisp-mode
	 lisp-interaction-mode
	 iel-mode))

;; rainbow-delimiters makes nested parentheses easier to
;; follow by showing each pair in its own color.
;; Depending on your theme, the colors might be very subtle,
;; and not very rainbow!
;; https://github.com/Fanael/rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t)
(setup (:package rainbow-delimiters)
  (:hook-into prog-mode))
