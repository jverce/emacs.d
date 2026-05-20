;;; 01-lib-language.el --- `my/define-language' helper -*- lexical-binding: t -*-
;;; Commentary:
;; A small declarative helper that wires up the common pattern shared by every
;; simple language module: file extensions in `auto-mode-alist', LSP startup,
;; format-on-save, and any extra hooks. Languages whose needs exceed the
;; helper (Python, JavaScript, Clojure, Markdown) stay imperative.
;;
;; Example:
;;
;;   (my/define-language yaml
;;     :mode yaml-mode
;;     :extensions ("\\.ya?ml\\'")
;;     :lsp t)
;;
;;   (my/define-language terraform
;;     :mode terraform-mode
;;     :formatter terraform-format-on-save-mode
;;     :extra-hooks (outline-minor-mode))
;;
;;   (my/define-language go
;;     :mode go-ts-mode
;;     :extensions ("\\.go\\'" "/go\\.mod\\'")
;;     :lsp t
;;     :save-hooks (lsp-format-buffer lsp-organize-imports))
;;
;; Argument reference:
;; - MODE        Major mode symbol; its hook is `<MODE>-hook'.
;; - EXTENSIONS  List of regexps mapped to MODE in `auto-mode-alist'.
;; - LSP         When non-nil, add `lsp-deferred' to `<MODE>-hook'.
;; - FORMATTER   Function symbol. If it ends in `-mode' it's enabled
;;               buffer-locally as a minor mode; otherwise it's installed
;;               on a buffer-local `before-save-hook'.
;; - SAVE-HOOKS  List of functions installed on a buffer-local
;;               `before-save-hook'. Use this when several formatters or
;;               organizers need to run on save.
;; - EXTRA-HOOKS List of function symbols appended to `<MODE>-hook'.
;;; Code:

(require 'cl-lib)

(defun my/--minor-mode-symbol-p (sym)
  "Return non-nil if SYM looks like a minor mode (its name ends in `-mode')."
  (and (symbolp sym)
       (string-suffix-p "-mode" (symbol-name sym))))

(cl-defmacro my/define-language
    (name &key mode extensions lsp formatter save-hooks extra-hooks)
  "Wire up a simple language module named NAME.

See the file commentary for the full argument reference."
  (declare (indent 1))
  (let* ((mode-sym (or mode
                       (error "my/define-language %s: :mode is required" name)))
         (hook (intern (format "%s-hook" mode-sym))))
    `(progn
       ,@(mapcar (lambda (ext) `(add-to-list 'auto-mode-alist '(,ext . ,mode-sym)))
                 extensions)
       ,@(when lsp
           `((add-hook ',hook #'lsp-deferred)))
       ,@(when formatter
           (if (my/--minor-mode-symbol-p formatter)
               `((add-hook ',hook #',formatter))
             `((add-hook ',hook
                         (lambda ()
                           (add-hook 'before-save-hook #',formatter nil t))))))
       ,@(when save-hooks
           `((add-hook ',hook
                       (lambda ()
                         ,@(mapcar
                            (lambda (fn)
                              `(add-hook 'before-save-hook #',fn nil t))
                            save-hooks)))))
       ,@(mapcar (lambda (fn) `(add-hook ',hook #',fn)) extra-hooks)
       ',name)))

(provide '01-lib-language)
;;; 01-lib-language.el ends here
