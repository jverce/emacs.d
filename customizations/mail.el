;; make sure mu4e is in your load-path
(add-to-list 'load-path "/opt/mu/share/emacs/site-lisp/mu4e")
(require 'mu4e)
(require 'smtpmail)

(setq mu4e-maildir "~/Mail")

(setq mu4e-sent-folder "/Amazon/Sent Items"
      mu4e-drafts-folder "/Amazon/Drafts"
      mu4e-trash-folder  "/Amazon/Deleted Items"
      user-mail-address "jvercell@amazon.com"
      smtpmail-default-smtp-server "ballard.amazon.com"
      smtpmail-local-domain "amazon.com"
      smtpmail-smtp-user "ANT\\jvercell"
      smtpmail-smtp-server "ballard.amazon.com"
      smtpmail-stream-type 'starttls
      smtpmail-smtp-service 1587)

;; If you face the CA issue as me:
;; (setq starttls-extra-arguments '("--x509cafile" "/usr/local/etc/openssl/certs/Amazon.com InfoSec CA G3.pem"))

(setq mu4e-get-mail-command "offlineimap"
      send-mail-function 'smtpmail-send-it
      ;; mu4e-update-interval 300 ;; I found updating interval is quite annoying; prefer to use "U" to do that explicitly
      message-kill-buffer-on-exit t)

;; http://www.djcbsoftware.nl/code/mu/mu4e/Displaying-rich_002dtext-messages.html#Displaying-rich_002dtext-messages
;; For Mac's HTML mails
;; (setq mu4e-html2text-command
;;       "textutil -stdin -format html -convert txt -stdout")
(setq mu4e-html2text-command "w3m -T text/html")

;; you can quickly switch to your Inbox -- press ja
(setq mu4e-maildir-shortcuts
      '(("/Amazon/INBOX"               . ?a)
      ;; Add others if needed.
       ))
;; http://www.djcbsoftware.nl/code/mu/mu4e/Bookmarks.html
;; Add new bookmarks to searches -- press br
(add-to-list 'mu4e-bookmarks
	     '("from:pipelines or from:p4admin or from:aloha-automation"
	       "Trash to Delete"
	       ?r))
