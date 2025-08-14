;;; -*- lexical-binding: t -*-
(use-package terraform-mode
  :ensure t)

(add-hook 'terraform-mode-hook #'outline-minor-mode)
(add-hook 'terraform-mode-hook 'terraform-format-on-save-mode)
