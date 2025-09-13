;;; -*- lexical-binding: t -*-
;; Remap python-mode to python-ts-mode AFTER python is loaded
(with-eval-after-load 'python
  (when (fboundp 'python-ts-mode)
    (add-to-list 'major-mode-remap-alist
                 '(python-mode . python-ts-mode))))

;; Install tree-sitter grammar if it's missing
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p)
           (not (treesit-language-available-p 'python)))
  (treesit-install-language-grammar 'python))

(use-package ruff-format
  :ensure t)

;; Format with Ruff on save in Python buffers
(add-hook 'python-ts-mode-hook #'ruff-format-on-save-mode)

(provide 'python)
