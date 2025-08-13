;; Remap python-mode to python-ts-mode AFTER python is loaded
(with-eval-after-load 'python
  (when (fboundp 'python-ts-mode)
    (add-to-list 'major-mode-remap-alist
                 '(python-mode . python-ts-mode))))

;; Set Python shell interpreter globally (optional)
(setq python-shell-interpreter "python3")

;; Install tree-sitter grammar if it's missing
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p)
           (not (treesit-language-available-p 'python)))
  (treesit-install-language-grammar 'python))

(provide 'python)
