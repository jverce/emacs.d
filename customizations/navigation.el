;; These customizations make it easier for you to navigate files,
;; switch buffers, and choose options from the minibuffer.

;; which-key is the best feature for the discoverability and
;; usability of Emacs. When you start a key sequence, e.g. C-x,
;; a menu opens up that shows you what all your next options
;; are. It's a great way to find out what's in Emacs, and it
;; helps transfer commands from your short-term memory to
;; your long-term memory and (finally) your muscle memory.
(setup (:package which-key)
  (which-key-mode)
  (:option which-key-idle-delay 0.3))

;; ivy is the completion framework. This makes M-x much more usable.
;; Installing counsel brings ivy and swiper as dependencies
;; swiper is a powerful search-within-a-buffer capability.
;; https://github.com/abo-abo/swiper
(setup (:package counsel)
  (ivy-mode)
  (:option ivy-use-virtual-buffers t
           ivy-re-builders-alist '((t . ivy--regex-ignore-order))
           ivy-count-format "%d/%d ")
  (:global "C-s" swiper
           "s-f" swiper
           "C-x C-f" counsel-find-file
           "C-x C-b" counsel-switch-buffer
           "M-x" counsel-M-x))

;; Turn on recent file mode so that you can more easily switch to
;; recently edited files when you first start emacs
(setq recentf-save-file (concat user-emacs-directory ".recentf"))
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 40)


;; ido-mode allows you to more easily navigate choices. For example,
;; when you want to switch buffers, ido presents you with a list
;; of buffers in the the mini-buffer. As you start to type a buffer's
;; name, ido will narrow down the list of buffers to match the text
;; you've typed in
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
(ido-mode t)

;; This allows partial matches, e.g. "tl" will match "Tyrion Lannister"
(setq ido-enable-flex-matching t)

;; Turn this behavior off because it's annoying
(setq ido-use-filename-at-point nil)

;; Don't try to match file across all "work" directories; only match files
;; in the current directory displayed in the minibuffer
(setq ido-auto-merge-work-directories-length -1)

;; Includes buffer names of recently open files, even if they're not
;; open now
(setq ido-use-virtual-buffers t)

;; This enables ido in all contexts where it could be useful, not just
;; for selecting buffer and file names
(ido-ubiquitous-mode t)
(ido-everywhere t)

;; Shows a list of buffers
(global-set-key (kbd "C-x C-b") 'ibuffer)


;; Enhances M-x to allow easier execution of commands. Provides
;; a filterable list of possible commands in the minibuffer
;; http://www.emacswiki.org/emacs/Smex
(setq smex-save-file (concat user-emacs-directory ".smex-items"))
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)

;; projectile everywhere!
(projectile-global-mode)

;; ivy-rich-mode adds docstrings and additional metadata
;; in the ivy picker minibuffer
;; see screenshots: https://github.com/Yevgnen/ivy-rich/blob/master/screenshots.org
(setup (:package ivy-rich)
  (ivy-rich-mode))
