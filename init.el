;; emacs kicker --- kick start emacs setup
;; Copyright (C) 2010 Dimitri Fontaine
;;
;; Author: Dimitri Fontaine <dim@tapoueh.org>
;; URL: https://github.com/dimitri/emacs-kicker
;; Created: 2011-04-15
;; Keywords: emacs setup el-get kick-start starter-kit
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/
;;
;; This file is NOT part of GNU Emacs.
(setq max-lisp-eval-depth 9999)
(setq max-specpdl-size 9999)
(server-start)
;; Cask setting
;;
(require 'cask "~/.cask/cask.el")
(cask-initialize)
(require 'pallet)

;; Path
;;
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; Python
;;
(require 'elpy)
(elpy-enable)
(elpy-use-ipython)

;; Ack
;;
(require 'ack-and-a-half)
;; Create shorter aliases
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)

;; Theme
;;
;; (load-theme 'sanityinc-tomorrow-day t)
;; (load-theme 'sanityinc-solarized-light t)
;; (load-theme 'sanityinc-solarized-dark t)
(load-theme 'spacegray t)

;; Magit
;;
(require 'magit)

(require 'cl)				; common lisp goodies, loop


;; el-get 
;;
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://github.com/dimitri/el-get/raw/master/el-get-install.el"
   (lambda (s)
     (end-of-buffer)
     (eval-print-last-sexp))))

;; now either el-get is `require'd already, or have been `load'ed by the
;; el-get installer.
;;(add-to-list 'load-path "~/.emacs.d/el-get/git-commit-mode")
;; set local recipes
(setq
 el-get-sources
 '((:name buffer-move			; have to add your own 
	  :after (progn
		   (global-set-key (kbd "<C-S-up>")     'buf-move-up)
		   (global-set-key (kbd "<C-S-down>")   'buf-move-down)
		   (global-set-key (kbd "<C-S-left>")   'buf-move-left)
		   (global-set-key (kbd "<C-S-right>")  'buf-move-right)))

   (:name smex				; a better (ido like) M-x
	  :after (progn
		   (setq smex-save-file "~/.emacs.d/.smex-items")
		   (global-set-key (kbd "M-x") 'smex)
		   (global-set-key (kbd "M-X") 'smex-major-mode-commands)))

   (:name emacs-flymake
	  :type git
	  :url "https://github.com/illusori/emacs-flymake"
	  :compile "flymake.el")

   (:name goto-last-change		; move pointer back to last change
	  :after (progn
		   ;; when using AZERTY keyboard, consider C-x C-_
		   (global-set-key (kbd "C-x C-/") 'goto-last-change)))))

;; now set our own packages
(setq
 my:el-get-packages
 '(el-get				; el-get is self-hosting
   escreen            			; screen for emacs, C-\ C-h
   switch-window			; takes over C-x o
   auto-complete			; complete as you type with overlays
   auto-complete-emacs-lisp
   auto-complete-yasnippet  ; yasnippet
   auto-complete-clang
   zencoding-mode			; http://www.emacswiki.org/emacs/ZenCoding
   powerline
   ))	                ; check out color-theme-solarized

;;
;; Some recipes require extra tools to be installed
;;
;; Note: el-get-install requires git, so we know we have at least that.
;;
;;(when (el-get-executable-find "cvs")
;;  (add-to-list 'my:el-get-packages 'emacs-goodies-el)) ; the debian addons for emacs

(when (el-get-executable-find "svn")
  (loop for p in '(psvn    		; M-x svn-status
		   yasnippet		; powerful snippet mode
		   )
	do (add-to-list 'my:el-get-packages p)))

(setq my:el-get-packages
      (append
       my:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)

(require 'powerline)

(require 'smartparens-config)
(smartparens-global-mode)
(show-smartparens-global-mode t)
(sp-with-modes '(rhtml-mode)
 (sp-local-pair "<" ">")
 (sp-local-pair "<%" "%>"))

(require 'flymake)
(setq flymake-run-in-place nil)
(setq temporary-file-directory "~/.emacs.d/tmp")

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/el-get/auto-complete/dict")

;; auto-complete-clang
(require 'auto-complete-clang)

;;(setq ac-auto-start nil)
;;(ac-set-trigger-key "TAB")
;;(ac-set-trigger-key "M-TAB")
;;(define-key ac-mode-map [(control tab)] 'auto-complete)
(defun my-ac-config ()
  (setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  ;; (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)
  (add-hook 'css-mode-hook 'ac-css-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))
(defun my-ac-cc-mode-setup ()
  (setq ac-sources (append '(ac-source-clang ac-source-yasnippet) ac-sources)))
(add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)

(require 'auto-complete-emacs-lisp)
(add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-setup)
;; ac-source-gtags
(my-ac-config)

;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)
(setq yas-snippet-dirs '("~/.emacs.d/el-get/yasnippet/snippets"))
(mapc 'yas-load-directory yas-snippet-dirs)


;; edbi
(require 'edbi)

(require 'e2wm)
(autoload 'e2wm:dp-edbi "e2wm-edbi" nil t)
(global-set-key (kbd "s-d") 'e2wm:dp-edbi)

;; IDO recentf
(require 'ido)
(require 'recentf)
(setq recentf-max-saved-items 25)
(recentf-mode 1)
(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let* ((file-assoc-list
	  (mapcar (lambda (x)
		    (cons (file-name-nondirectory x)
			  x))
		  recentf-list))
	 (filename-list
	  (remove-duplicates (mapcar #'car file-assoc-list)
			     :test #'string=))
	 (filename (ido-completing-read "Choose recent file: "
					filename-list
					nil
					t)))
    (when filename
      (find-file (cdr (assoc filename
			     file-assoc-list))))))

;; ESS
(require 'ess-site)
(setq ess-use-auto-complete t)

;; Web-mode
;;
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-code-indent-offset 4))
(add-hook 'web-mode-hook 'web-mode-hook)

;; on to the visual settings
(setq inhibit-splash-screen t)		; no splash screen, thanks
(line-number-mode 1)			; have line numbers and
(column-number-mode 1)			; column numbers in the mode line

(setq indent-tabs-mode nil) ; insert spaces instead of tabs

;;(show-paren-mode 1)
(tool-bar-mode -1)			; no tool bar with icons
(scroll-bar-mode -1)			; no scroll bars
(unless (string-match "apple-darwin" system-configuration)
  ;; on mac, there's always a menu bar drown, don't have it empty
  (menu-bar-mode -1))

;; choose your own fonts, in a system dependant way
(if (string-match "apple-darwin" system-configuration)
    (set-face-font 'default "Monaco-12")
  (set-face-font 'default "Monospace-10"))

(global-hl-line-mode)			; highlight current line
(global-linum-mode 1)			; add line numbers on the left
(global-auto-complete-mode)		; auto-complete mode

;; avoid compiz manager rendering bugs
(add-to-list 'default-frame-alist '(alpha . 100))

;; copy/paste with C-c and C-v and C-x, check out C-RET too
(cua-mode)

;; under mac, have Command as Meta and keep Option for localized input
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
;;  (setq mac-command-modifier 'meta)
;;  (setq mac-option-modifier 'none)
  ;; Encoding system
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (setq mac-control-modifier 'control)
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super)
  (setq ns-function-modifier 'hyper)
  )

;; Use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t
      save-place-file (concat user-emacs-directory "places")
      backup-directory-alist `(("." . ,(concat user-emacs-directory
					       "backups"))))

;; Navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

; winner-mode provides C-<left> to get back to previous window layout
(winner-mode 1)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its
;; content to reflect what's on-disk.
(global-auto-revert-mode 1)

;; M-x shell is a nice shell interface to use, let's make it colorful.  If
;; you need a terminal emulator rather than just a shell, consider M-x term
;; instead.
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; If you do use M-x term, you will notice there's line mode that acts like
;; emacs buffers, and there's the default char mode that will send your
;; input char-by-char, so that curses application see each of your key
;; strokes.
;;
;; The default way to toggle between them is C-c C-j and C-c C-k, let's
;; better use just one key to do the same.
(require 'term)

;; use ido for minibuffer completion
(require 'ido)
(ido-mode t)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-show-dot-for-dired t)

;; C-x C-j opens dired with the cursor right on the file you're editing
(require 'dired-x)
(require 'dired+)

;; full screen
(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
		       (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)

;; Default Windows Size
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
    (progn
      (if (> (x-display-pixel-width) 1280)
        (add-to-list 'default-frame-alist (cons 'width 200))
        (add-to-list 'default-frame-alist (cons 'width 80)))
      (add-to-list 'default-frame-alist
                   (cons 'height (/ (- (x-display-pixel-height) 200)
                                    (frame-char-height)))))))

(set-frame-size-according-to-resolution)

;; Org-mode
(add-hook 'org-mode-hook (lambda ()  (setq org-agenda-include-diary t)))
(setq org-default-notes-file "~/Documents/Orgs/notes.org")

;; Diary
(setq diary-file "~/Dropbox/diary")
(display-time)
                    ;(add-hook 'diary-hook 'appt-make-list)
(diary 0)

(setq view-diary-entries-initially t
      mark-diary-entries-in-calendar t
      number-of-diary-entries 7)
(add-hook 'diary-display-hook 'fancy-diary-display)
(add-hook 'today-visible-calendar-hook 'calendar-mark-today)

(defun diary-countdown (m1 d1 y1 n)
  "Reminder during the previous n days to the date.
    Order of parameters is M1, D1, Y1, N if
    `european-calendar-style' is nil, and D1, M1, Y1, N otherwise."
  (diary-remind '(diary-date m1 d1 y1) (let (value) (dotimes (number n value) (setq value (cons number value))))))

;; Expand-region
(require 'expand-region)

;; flx-ido
(require 'flx-ido)
(flx-ido-mode 1)
;;(setq flx-ido-threshhold 1000)

;; Project Management
;;
(require 'ack-and-a-half)
(require 'projectile)
(projectile-global-mode)
(setq projectile-completion-system 'grizzl)

;; JS2mode
;;
(require 'js2-mode)
(setq js2-bounce-indent-p t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))

(setq my-emacs-root "~/.emacs.d/")
(setenv "NODE_PATH" (concat (getenv "NODE_PATH") (if (getenv "NODE_PATH") path-separator "") (concat my-emacs-root "node_modules/")))
(setenv "NODE_NO_READLINE" "1")
;; (require 'ac-js2)
;; (require 'auto-complete)
(require 'js2-imenu-extras)
(add-hook 'js2-mode-hook 'js2-imenu-extras-mode)
(add-hook 'js2-mode-hook 'skewer-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)
(setq ac-js2-evaluate-calls t)

(js2-imenu-extras-setup)
;; Use lambda for anonymous functions
(font-lock-add-keywords
 'js2-mode `(("\\(function\\) *("
              (0 (progn (compose-region (match-beginning 1)
                                        (match-end 1) "\u0192")
                        nil)))))

;; Use right arrow for return in one-line functions
(font-lock-add-keywords
 'js2-mode `(("function *([^)]*) *{ *\\(return\\) "
              (0 (progn (compose-region (match-beginning 1)
                                        (match-end 1) "\u2190")
                        nil)))))


(eval-after-load "js2-mode"
  '(progn
     (setq js2-missing-semi-one-line-override t)
     (setq-default js2-basic-offset 4) ; 2 spaces for indentation (if you prefer 2 spaces instead of default 4 spaces for tab)

     ;; add from jslint global variable declarations to js2-mode globals list
     ;; modified from one in http://www.emacswiki.org/emacs/Js2Mode
     (defun my-add-jslint-declarations ()
       (when (> (buffer-size) 0)
         (let ((btext (replace-regexp-in-string
                       (rx ":" (* " ") "true") " "
                       (replace-regexp-in-string
                        (rx (+ (char "\n\t\r "))) " "
                        ;; only scans first 1000 characters
                        (save-restriction (widen) (buffer-substring-no-properties (point-min) (min (1+ 1000) (point-max)))) t t))))
           (mapc (apply-partially 'add-to-list 'js2-additional-externs)
                 (split-string
                  (if (string-match (rx "/*" (* " ") "global" (* " ") (group (*? nonl)) (* " ") "*/") btext)
                      (match-string-no-properties 1 btext) "")
                  (rx (* " ") "," (* " ")) t))
           )))
     (add-hook 'js2-post-parse-callbacks 'my-add-jslint-declarations)))

(require 'js2-refactor)

(require 'tern)
(when (executable-find "tern")
  (add-hook 'js2-mode-hook (lambda () (tern-mode t)))
  (eval-after-load 'auto-complete
    '(eval-after-load 'tern
       '(progn
	  (require 'tern-auto-complete)
	  (tern-ac-setup)))))


;; Helm
;;
(require 'helm-config)
(helm-mode 1)

;; Key bindings
;;
(global-set-key (kbd "C-c h") 'helm-mini)

(js2r-add-keybindings-with-prefix "C-c C-m")

(global-set-key "\C-cd" 'dash-at-point) ;; dash-at-point

(sp-use-smartparens-bindings)

(define-key sp-keymap (kbd "C-{") 'sp-select-previous-thing)
(define-key sp-keymap (kbd "C-}") 'sp-select-next-thing)
(global-set-key (kbd "H-SPC") 'set-rectangular-region-anchor)
(global-set-key (kbd "C-x r q") 'save-buffers-kill-terminal)

(global-set-key (kbd "C-x g") 'magit-status)

(global-set-key (kbd "H-+") 'er/expand-region)
(global-set-key (kbd "H-_") 'er/contract-region)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cl" 'org-store-link)

(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-c") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-r") 'recentf-ido-find-file)

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(global-set-key "\C-ct" 'google-translate-at-point)

;; Have C-y act as usual in term-mode, to avoid C-' C-y C-'
;; Well the real default would be C-c C-j C-y C-c C-k.
(define-key term-raw-map  (kbd "C-y") 'term-paste)

(define-key term-raw-map  (kbd "C-'") 'term-line-mode)
(define-key term-mode-map (kbd "C-'") 'term-char-mode)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(require 'grizzl)
(projectile-global-mode)

(setq projectile-enable-caching t)
(setq projectile-completion-system 'grizzl)
;; Press Command-p for fuzzy find in project
(global-set-key (kbd "s-f") 'projectile-find-file)
(global-set-key (kbd "C-c p f") 'find-file-in-project)
(global-set-key (kbd "s-p") 'projectile-switch-project)
;; Press Command-b for fuzzy switch buffer
(global-set-key (kbd "s-b") 'projectile-switch-to-buffer)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bmkp-last-as-first-bookmark-file "~/.emacs.d/bookmarks")
 '(custom-safe-themes (quote ("bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" default)))
 '(org-agenda-files (quote ("~/Documents/Orgs/todo.org" "~/Documents/Orgs/work.org"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)
