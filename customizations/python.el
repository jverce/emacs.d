(use-package python-mode
  :ensure t)

(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
