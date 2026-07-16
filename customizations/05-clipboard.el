;;; 05-clipboard.el --- Terminal clipboard integration -*- lexical-binding: t -*-
;;; Commentary:
;; Copy and paste through OS utilities when Emacs has no graphical frame.
;;; Code:

(require 'subr-x)

(defvar my/terminal-clipboard--backend nil
  "Commands used to exchange text with the local OS clipboard.")

(defun my/terminal-clipboard-backend ()
  "Return commands for the available local terminal clipboard backend."
  (cond
   ((and (eq system-type 'darwin)
         (executable-find "pbcopy")
         (executable-find "pbpaste"))
    '(:copy ("pbcopy") :paste ("pbpaste")))
   ((and (eq system-type 'gnu/linux)
         (getenv "WAYLAND_DISPLAY")
         (executable-find "wl-copy")
         (executable-find "wl-paste"))
    '(:copy ("wl-copy" "--type" "text/plain")
      :paste ("wl-paste" "--no-newline")))
   ((and (eq system-type 'gnu/linux)
         (getenv "DISPLAY")
         (executable-find "xclip"))
    '(:copy ("xclip" "-selection" "clipboard")
      :paste ("xclip" "-selection" "clipboard" "-o")))))

(defun my/terminal-clipboard--copy (text)
  "Copy TEXT through the configured terminal clipboard backend."
  (let ((command (plist-get my/terminal-clipboard--backend :copy)))
    (with-temp-buffer
      (insert text)
      (apply #'call-process-region (point-min) (point-max)
             (car command) nil nil nil (cdr command)))))

(defun my/terminal-clipboard--paste ()
  "Return clipboard text from the configured terminal clipboard backend."
  (let ((command (plist-get my/terminal-clipboard--backend :paste)))
    (with-temp-buffer
      (when (zerop (apply #'call-process (car command) nil t nil (cdr command)))
        (buffer-string)))))

(defun my/enable-terminal-clipboard ()
  "Enable OS clipboard integration when a terminal backend is available."
  (when-let ((backend (my/terminal-clipboard-backend)))
    (setq my/terminal-clipboard--backend backend
          interprogram-cut-function #'my/terminal-clipboard--copy
          interprogram-paste-function #'my/terminal-clipboard--paste)))

(my/enable-terminal-clipboard)

(provide '05-clipboard)
;;; 05-clipboard.el ends here
