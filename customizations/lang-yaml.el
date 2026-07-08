;;; lang-yaml.el --- YAML editing with LSP -*- lexical-binding: t -*-
;;; Commentary:
;; yaml-mode plus lsp-deferred for `.yml' / `.yaml' files.
;; YAML is intentionally excluded from `treesit-auto-langs' in editing.el
;; because the upstream tree-sitter grammar isn't yet a good fit.
;;; Code:

(use-package yaml-mode
  :ensure t)

(my/define-language yaml
  :mode yaml-mode
  :extensions ("\\.ya?ml\\'")
  :lsp t
  :extra-hooks (my/yaml-outline-setup))

;; yaml-mode derives from text-mode, so it misses the prog-mode hideshow hook,
;; and hideshow can't parse indentation syntax anyway. Outline fills the gap.
(defun my/yaml-outline-setup ()
  "Fold YAML blocks by indentation with `outline-minor-mode'."
  ;; ponytail: regexp heuristic, not a YAML parser — unquoted keys with
  ;; spaces/dots won't fold; switch to LSP folding ranges if that ever matters.
  (setq-local outline-regexp
              "^ *\\(?:- \\)?\\(?:[a-zA-Z0-9_-]+\\|\"[^\"]*\"\\|'[^']*'\\) *:")
  (setq-local outline-level
              (lambda ()
                (save-excursion
                  (beginning-of-line)
                  ;; "- key:" list items conventionally sit at the parent
                  ;; key's column, so the "- " marker counts as one level.
                  (+ 1 (/ (current-indentation) yaml-indent-offset)
                     (if (looking-at-p " *- ") 1 0)))))
  (outline-minor-mode 1))

(provide 'lang-yaml)
;;; lang-yaml.el ends here
