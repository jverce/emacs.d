;;; 16-prose-checking.el --- Spelling and grammar checking -*- lexical-binding: t -*-
;;; Commentary:
;; Jinx provides fast local spell checking via Enchant.  Harper provides local
;; grammar/style diagnostics over LSP and checks comments only in supported
;; programming languages.
;;; Code:

(require 'seq)

(defvar my/jinx-missing-dictionary-warning-shown nil)

(defun my/jinx-dictionary-installer-command ()
  (abbreviate-file-name
   (expand-file-name "scripts/install-spell-dictionaries.sh" user-emacs-directory)))

(defun my/jinx-mode-if-dictionaries ()
  "Enable `jinx-mode' only when Enchant can load a dictionary.
Without dictionaries Jinx treats every word as misspelled, which makes prose
buffers unusable."
  (condition-case err
      (progn
        (jinx-mode 1)
        (unless (bound-and-true-p jinx--dicts)
          (jinx-mode -1)
          (unless my/jinx-missing-dictionary-warning-shown
            (setq my/jinx-missing-dictionary-warning-shown t)
            (message
             "Jinx disabled: no Enchant dictionaries for %s. Run %s."
             jinx-languages
             (my/jinx-dictionary-installer-command)))))
    (error
     (message "Jinx disabled: %s" (error-message-string err)))))

(use-package jinx
  :ensure t
  :hook ((text-mode prog-mode conf-mode git-commit-mode) . my/jinx-mode-if-dictionaries)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(defconst my/harper-language-id-by-mode
  '((text-mode . "plaintext")
    (markdown-mode . "markdown")
    (gfm-mode . "markdown")
    (org-mode . "org")
    (git-commit-mode . "gitcommit")
    (python-mode . "python")
    (python-ts-mode . "python")
    (js-mode . "javascript")
    (js-ts-mode . "javascript")
    (typescript-ts-mode . "typescript")
    (tsx-ts-mode . "typescriptreact")
    (go-mode . "go")
    (go-ts-mode . "go")
    (clojure-mode . "clojure")
    (clojurescript-mode . "clojure")
    (sh-mode . "shellscript")
    (bash-ts-mode . "shellscript")
    (ruby-mode . "ruby")
    (ruby-ts-mode . "ruby")
    (html-mode . "html")
    (nix-mode . "nix")
    (toml-ts-mode . "toml"))
  "Major modes and language identifiers supported by harper-ls.")

(defun my/harper-supported-mode-p ()
  (seq-some (lambda (entry) (derived-mode-p (car entry)))
            my/harper-language-id-by-mode))

(defun my/harper-language-id (_workspace)
  (or (seq-some (lambda (entry)
                  (when (derived-mode-p (car entry))
                    (cdr entry)))
                my/harper-language-id-by-mode)
      "plaintext"))

(defun my/harper-server-command ()
  "Return the harper-ls command, preferring a system install.
Falls back to the lsp-mode-managed Cargo install path."
  (list (or (executable-find "harper-ls")
            (lsp-package-path 'harper-ls))
        "--stdio"))

(defun my/harper-start ()
  (lsp-deferred))

(with-eval-after-load 'lsp-mode
  (lsp-dependency 'harper-ls
                  '(:system "harper-ls")
                  '(:cargo :package "harper-ls"
                           :path "harper-ls"))

  (lsp-register-custom-settings
   '(("harper-ls.linters.SpellCheck" nil t)
     ("harper-ls.linters.SentenceCapitalization" nil t)
     ("harper-ls.diagnosticSeverity" "hint")))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'my/harper-server-command)
    :activation-fn (lambda (_filename &optional _mode)
                     (my/harper-supported-mode-p))
    :language-id #'my/harper-language-id
    :add-on? t
    :priority -2
    :server-id 'harper-ls
    :download-server-fn (lambda (_client callback error-callback _update?)
                          (lsp-package-ensure 'harper-ls callback error-callback)))))

(dolist (hook '(text-mode-hook
                markdown-mode-hook
                gfm-mode-hook
                org-mode-hook
                git-commit-mode-hook))
  (add-hook hook #'my/harper-start))

(provide '16-prose-checking)
;;; 16-prose-checking.el ends here
