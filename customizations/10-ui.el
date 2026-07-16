;;; 10-ui.el --- Frame, theme, modeline, and font setup -*- lexical-binding: t -*-
;;; Commentary:
;; UI-only customizations: chrome, fonts, theme, modeline, GUI selections.
;;; Code:

(tooltip-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode 0)
(setq create-lockfiles nil)
(fset 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)

;; Enable fuzzy search/matching as a fallback completion style.
(add-to-list 'completion-styles 'flex t)

;; Show full path in title bar.
(setq-default frame-title-format "%b (%f)")

;; Initial frame size.
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 100))

;; Increase default font size for readability.
(set-face-attribute 'default nil :height 110)

;; Your choice of font is very personal; install it on your system first.
(set-face-attribute 'default nil :font "FiraCode Nerd Font")

;; On macOS, swallow Cmd-T (the system font menu) to keep the keystroke free.
(when (eq system-type 'darwin)
  (global-set-key (kbd "s-t") #'ignore))

;; doom-modeline is a more modern, more beautiful modeline. It uses icons from
;; all-the-icons. After first install, run `M-x all-the-icons-install-fonts`.
(use-package all-the-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :if (not (eq system-type 'windows-nt))
  :config (doom-modeline-mode 1))

;; GitHub Dark Dimmed theme is loaded from the themes/github submodule.
(use-package autothemer
  :ensure t)

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/github/" user-emacs-directory))
(load-theme 'github-dark-dimmed t)

;; GUI selection integration. Terminal clipboard support is in 05-clipboard.el.
(setq select-enable-clipboard t
      x-select-enable-clipboard t
      x-select-enable-clipboard-manager t
      select-enable-primary t
      x-select-enable-primary t
      ;; Save clipboard strings into the kill ring before replacing them, so an
      ;; external selection isn't lost when something is killed in Emacs first.
      save-interprogram-paste-before-kill t
      ;; Show all options in apropos.
      apropos-do-all t
      ;; Mouse yank at point, not at click.
      mouse-yank-at-point t)

(provide '10-ui)
;;; 10-ui.el ends here
