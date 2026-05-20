;;; lang-clojure.el --- Clojure / ClojureScript toolchain -*- lexical-binding: t -*-
;;; Commentary:
;; clojure-mode + CIDER + clj-refactor + cider-hydra + paredit.
;; subword-mode treats CamelCase tokens (e.g. JavaClassName) as separate words
;; for movement and editing.
;;; Code:

(use-package clojure-mode
  :ensure t
  :hook ((clojure-mode . subword-mode)
         (clojure-mode . paredit-mode)
         (clojure-mode . lsp)))

;; CIDER is a complete interactive Clojure development environment.
;; https://docs.cider.mx/cider/
(use-package cider
  :ensure t
  :bind (("C-c u"   . cider-user-ns)
         ("C-M-r"   . cider-refresh))
  :custom
  (cider-show-error-buffer t)
  (cider-auto-select-error-buffer t)
  (cider-repl-history-file (concat user-emacs-directory "cider-history"))
  (cider-repl-pop-to-buffer-on-connect t)
  (cider-repl-wrap-history t)
  :hook (cider-repl-mode . paredit-mode))

;; cider-hydra provides discoverable command menus (M-x with cider-hydra prefix).
;; https://github.com/clojure-emacs/cider-hydra
(use-package cider-hydra
  :ensure t
  :hook (clojure-mode . cider-hydra-mode))

;; clj-refactor adds refactorings on top of CIDER (e.g. add missing libspec,
;; extract function, destructure keys).
;; https://github.com/clojure-emacs/clj-refactor.el
(use-package clj-refactor
  :ensure t
  :hook (clojure-mode . clj-refactor-mode)
  :config (cljr-add-keybindings-with-prefix "C-c C-m"))

;; Use clojure-mode for additional extensions.
(add-to-list 'auto-mode-alist '("\\.boot\\'"   . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs.*\\'" . clojure-mode))

;; Web-app development helpers.
(defun cider-start-http-server ()
  (interactive)
  (cider-load-buffer)
  (let ((ns (cider-current-ns)))
    (cider-repl-set-ns ns)
    (cider-interactive-eval (format "(println '(def server (%s/start))) (println 'server)" ns))
    (cider-interactive-eval (format "(def server (%s/start)) (println server)" ns))))

(defun cider-refresh ()
  (interactive)
  (cider-interactive-eval "(user/reset)"))

(defun cider-user-ns ()
  (interactive)
  (cider-repl-set-ns "user"))

(provide 'lang-clojure)
;;; lang-clojure.el ends here
