;;; lang-terraform.el --- Terraform editing -*- lexical-binding: t -*-
;;; Commentary:
;; terraform-mode + format-on-save + outline-minor-mode for navigation.
;;; Code:

(use-package terraform-mode
  :ensure t)

(my/define-language terraform
  :mode terraform-mode
  :formatter terraform-format-on-save-mode
  :extra-hooks (outline-minor-mode))

(provide 'lang-terraform)
;;; lang-terraform.el ends here
