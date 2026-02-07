;;; -*- lexical-binding: t -*-
;; Emacs comes with package.el for installing packages.
;; Try M-x list-packages to see what's available.
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Retry package installs to handle transient network/archive failures.
(defvar my/package-bootstrap-max-retries 3)
(defvar my/package-bootstrap-retry-delay 2)

(defun my/ensure-package-with-retries (pkg &optional retries delay)
  (let* ((max-attempts (or retries my/package-bootstrap-max-retries))
         (retry-delay (or delay my/package-bootstrap-retry-delay))
         (attempt 1)
         (installed (package-installed-p pkg))
         last-error)
    (while (and (not installed) (<= attempt max-attempts))
      (condition-case err
          (progn
            (package-refresh-contents)
            (package-install pkg)
            (setq installed (package-installed-p pkg)))
        (error
         (setq last-error err)
         (when (< attempt max-attempts)
           (sleep-for retry-delay))))
      (setq attempt (1+ attempt)))
    (unless installed
      (error
       "Failed to install `%s` after %d attempt(s): %s"
       pkg
       max-attempts
       (if last-error
           (error-message-string last-error)
         "unknown error")))
    installed))

(defun my/ensure-required-packages ()
  (dolist (pkg '(setup flycheck lsp-mode ruff-format))
    (my/ensure-package-with-retries pkg)))

(my/ensure-required-packages)

;; Copy PATH from a deterministic login shell.
;; launchctl can set SHELL to /bin/sh for daemon sessions, so we map by OS.
(let* ((preferred-shell (cond
                         ((eq system-type 'darwin) "/bin/zsh")
                         ((eq system-type 'gnu/linux) "/bin/bash")
                         (t "/bin/sh")))
       (login-shell (if (file-exists-p preferred-shell)
                        preferred-shell
                      "/bin/sh"))
       (shell-path-cmd (format "%s -l -c 'printf %%s \"$PATH\"'" (shell-quote-argument login-shell)))
       (shell-path (string-trim-right (shell-command-to-string shell-path-cmd)))
       (path (concat (getenv "HOME") "/.asdf/shims:" shell-path)))
  (setenv "PATH" path)
  (setq exec-path (parse-colon-path path)))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode)
  (setq envrc-show-summary-in-minibuffer nil))

;; setup.el provides a macro for configuration patterns
;; it makes package installation and config nice and tidy!
;; https://www.emacswiki.org/emacs/SetupEl
(require 'setup)

;; All other features are loaded one by one from
;; the customizations directory. Read those files
;; to find out what they do.
(add-to-list 'load-path "~/.emacs.d/customizations")

(defvar addons
  '("ui.el"
    "navigation.el"
    "projects.el"
    "git.el"
    "filetree.el"
    "editing.el"
    "lsp.el"
    "languages.el"
    "go.el"
    "terraform.el"
    "setup-python.el"
    "setup-yaml.el"
    "elisp-editing.el"
    "setup-clojure.el"
    "setup-js.el"
    "shell-integration.el"))

(dolist (x addons)
  (load x))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)
