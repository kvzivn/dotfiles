;; init.el - where it all begins

(add-to-list 'load-path "~/.emacs.d/lisp")

;;; Package configuration
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(require 'package)
(eval-after-load "package"
  '(progn
     (add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/"))
     (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
     (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
     (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))))

(package-initialize)
;; required because of a package.el bug
(setq url-http-attempt-keepalives nil)

(defvar elpa-packages
  '(ac-dabbrev
    ace-jump-mode
    ack-and-a-half
    browse-kill-ring
    buffer-move
    crontab-mode
    csv-mode
    dash
    diminish
    discover-my-major
    dockerfile-mode
    epl
    expand-region
    fill-column-indicator
    flx
    flx-ido
    flycheck
    fringe-helper
    gist
    git-commit-mode
    gitconfig-mode
    gitignore-mode
    helm
    helm-projectile
    helm-swoop
    htmlize
    httpcode
    ido-ubiquitous
    ido-vertical-mode
    ioccur
    js2-mode
    magit
    markdown-mode
    melpa
    nginx-mode
    otp
    paradox
    paredit
    pkg-info
    projectile
    puppet-mode
    rainbow-delimiters
    rainbow-identifiers
    rainbow-mode
    rich-minority
    smart-mode-line
    smex
    ssh-config-mode
    virtualenvwrapper
    yaml-mode
    yasnippet
    zenburn)
  "A list of packages to ensure are installed at launch.")

(when (not package-archive-contents)
  (package-refresh-contents))

(dolist (pkg elpa-packages)
  (when (and (not (package-installed-p pkg))
           (assoc pkg package-archive-contents))
    (package-install pkg)))

(defun package-list-unaccounted-packages ()
  "Like `package-list-packages', but shows only the packages that
  are installed and are not in `elpa-packages'.  Useful for
  cleaning out unwanted packages."
  (interactive)
  (package-show-package-list
   (remove-if-not (lambda (x) (and (not (memq x elpa-packages))
                            (not (package-built-in-p x))
                            (package-installed-p x)))
                  (mapcar 'car package-archive-contents))))


;;; Options and settings
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default indicate-empty-lines t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(mouse-wheel-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t
      initial-scratch-message ";; *scratch*\n\n")

(setq backup-inhibited t
      auto-save-default t)

(setq backup-by-copying t)

;; Save all tempfiles in $TMPDIR/emacs$UID/
(defconst emacs-tmp-dir
  (format "%s/%s-%s/" temporary-file-directory "emacs" (user-uid)))
(make-directory emacs-tmp-dir t)
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t)))

(setq auto-save-list-file-prefix
      emacs-tmp-dir)

(setq auto-save-interval 1
      auto-save-timeout 1)

(setq echo-keystrokes 0.4
      stack-trace-on-error nil
      standard-indent 4
      tab-always-indent 'complete
      grep-scroll-output t)

(setq-default comment-column 42
              fill-column 78
              indent-tabs-mode nil
              tab-width 4
              word-wrap t)

(show-paren-mode t)
(global-auto-revert-mode t)

;;; Helm
(require 'helm)
(require 'helm-config)

(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-set-key (kbd "C-x f") 'projectile-find-file) ; Until helm-projectile doesn't crash
(global-set-key (kbd "M-q") 'helm-mini)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

;; helm-swoop
(require 'helm-swoop)

;; Change the keybinds to whatever you like :)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
(global-set-key (kbd "C-c M-i") 'helm-multi-swoop)
(global-set-key (kbd "C-x M-i") 'helm-multi-swoop-all)

;; When doing isearch, hand the word over to helm-swoop
(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
;; From helm-swoop to helm-multi-swoop-all
(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
;; When doing evil-search, hand the word over to helm-swoop
;; (define-key evil-motion-state-map (kbd "M-i") 'helm-swoop-from-evil-search)

;; Move up and down like isearch
(define-key helm-swoop-map (kbd "C-r") 'helm-previous-line)
(define-key helm-swoop-map (kbd "C-s") 'helm-next-line)
(define-key helm-multi-swoop-map (kbd "C-r") 'helm-previous-line)
(define-key helm-multi-swoop-map (kbd "C-s") 'helm-next-line)

;; Save buffer when helm-multi-swoop-edit complete
(setq helm-multi-swoop-edit-save t)

;; If this value is t, split window inside the current window
(setq helm-swoop-split-with-multiple-windows nil)

;; Split direcion. 'split-window-vertically or 'split-window-horizontally
(setq helm-swoop-split-direction 'split-window-vertically)

;; If nil, you can slightly boost invoke speed in exchange for text color
(setq helm-swoop-speed-or-color nil)

;; ;; Go to the opposite side of line from the end or beginning of line
(setq helm-swoop-move-to-line-cycle t)

;; Optional face for line numbers
;; Face name is `helm-swoop-line-number-face`
(setq helm-swoop-use-line-number-face t)

(helm-mode 1)

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x b") 'helm-mini)

;;; Projectile
(require 'projectile)
(projectile-global-mode)
(setq projectile-completion-system 'helm)

;;; Smart mode line
(require 'smart-mode-line)
(setq sml/no-confirm-load-theme t)
(sml/setup)
(sml/apply-theme 'dark)

(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-x C-z") 'undo)

;;; FCI
(require 'fill-column-indicator)
(fci-mode 1)
(setq fci-rule-width 1)
(setq fci-rule-color "#000000")
(add-hook 'after-change-major-mode-hook 'fci-mode)

;;; ediff
(setq ediff-diff-options "-w")
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;; Rainbows <3
(add-hook 'emacs-lisp-mode-hook 'rainbow-identifiers-mode)

;;; Editor macros
(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
   If there's no region, the current line will be duplicated. However, if
   there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(global-set-key (kbd "C-d") 'duplicate-current-line-or-region)

(global-set-key (kbd "M-k")
                (lambda ()
                  (interactive)
                  (beginning-of-line)
                  (kill-line 1)
                  (back-to-indentation)))

(defun yank-entire-line ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (set-mark-command)
    (end-of-line)
    (kill-ring-save)))

(defun back-to-indentation-or-beginning ()
  "Go to first non whitespace character on a line, or if already on the first
  non whitespace character, go to the beginning of the line."
  (interactive)
  (if (= (point) (save-excursion (back-to-indentation) (point)))
      (beginning-of-line)
    (back-to-indentation)))

(defun move-end-of-line-or-next-line ()
  (interactive)
  (if (eolp)
      (next-line)
    (move-end-of-line nil)))

(defun insertline-and-move-to-line (&optional up)
  "Insert an empty line after the current line and positon
  the curson at its beginning, according to the current mode."
  (interactive)
  (if up
      (previous-line))
  (move-end-of-line nil)
  (open-line 1)
  (forward-line 1)
  (indent-according-to-mode))

(global-set-key [remap goto-line] 'goto-line-with-feedback)

(defun goto-line-with-feedback ()
  "Show line numbers temporarily, while prompting for the line number input"
  (interactive)
  (unwind-protect
      (progn
        (linum-mode 1)
        (goto-line (read-number "Goto line: ")))
    (linum-mode -1)))

(global-set-key (kbd "C-c g") 'goto-line)
(global-set-key (kbd "C-a") 'back-to-indentation-or-beginning)
(global-set-key (kbd "C-e") 'move-end-of-line-or-next-line)
(global-set-key (kbd "C-o") 'insertline-and-move-to-line)
(global-set-key (kbd "C-M-o") (lambda ()
                                (interactive)
                                (insertline-and-move-to-line t)))

(global-set-key (kbd "M-j")
                (lambda ()
                  (interactive)
                  (join-line -1)))

;;; magit
(require 'magit)
(global-set-key (kbd "M-g") 'magit-status)

(setq magit-save-some-buffers 'dontask
      )

(defadvice magit-status (around magit-fullscreen activate)
  (window-configuration-to-register :magit-fullscreen)
  ad-do-it
  (delete-other-windows))

(defadvice magit-mode-quit-window (after magit-restore-screen activate)
  "Restores the previous window configuration and kills the magit buffer"
  (jump-to-register :magit-fullscreen))

(define-key magit-status-mode-map (kbd "q") 'magit-mode-quit-window)


;;; Python
(require 'pytest)
(require 'snakecharmer)

;;; Misc options
(global-set-key (kbd "C-c C-e") 'eval-buffer)
(global-set-key (kbd "<escape>")      'keyboard-escape-quit)

(setq debug-on-error t)

;; expand-region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)


;;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)


;;; ido settings
(setq ido-create-new-buffer 'always
      ido-default-buffer-method 'selected-window
      ido-case-fold t
      ido-enable-last-directory-history nil
      ido-use-filename-at-point nil
      ido-use-url-at-point nil
      ido-enable-flex-matching t
      ido-max-prospects 15
      ido-confirm-unique-completion t
      ido-decorations '("\n-> " "" "\n   " "\n   ..." "[" "]"
                        " [No match]" " [Matched]" " [Not readable]"
                        " [Too big]" " [Confirm]"))

(require 'ido)
(ido-mode t)
(ido-everywhere t)

;; pls no .elc
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (make-local-variable 'after-save-hook)
            (add-hook 'after-save-hook
                      (lambda ()
                        (if (file-exists-p (concat buffer-file-name "c"))
                            (delete-file (concat buffer-file-name "c")))))))

;; Scratch buffer go
(define-key global-map (kbd "C-<f5>")
  (lambda ()
    (interactive)
    (let ((content initial-scratch-message)
          (buf "*scratch*"))
      (when (get-buffer buf)
        (setq content ""))
      (switch-to-buffer buf)
      (insert content))))

;; Org buffer go
(define-key global-map (kbd "<f4>")
  (lambda ()
    (interactive)
    (find-file (concat user-emacs-directory "todo.org"))))

;;; Backups
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
        (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 2               ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 20            ; number of keystrokes between auto-saves (default: 300)
      )

;;; Window management
(define-key global-map (kbd "M-0") 'delete-window)
(define-key global-map (kbd "M-1") 'delete-other-windows)
(define-key global-map (kbd "M-2") 'split-window-vertically)
(define-key global-map (kbd "M-3") 'split-window-horizontally)
(define-key global-map (kbd "M-4") 'kill-buffer-and-window)
(define-key global-map (kbd "M-=") 'balance-windows)

(global-set-key (kbd "C-x h") 'windmove-left)
(global-set-key (kbd "C-x j") 'windmove-down)
(global-set-key (kbd "C-x k") 'windmove-up)
(global-set-key (kbd "C-x l") 'windmove-right)

(global-set-key (kbd "C-x C-j")
                (lambda ()
                  (interactive)
                  (split-window-below)
                  (windmove-down)))

(global-set-key (kbd "C-x C-l")
                (lambda ()
                  (interactive)
                  (split-window-right)
                  (windmove-right)))

(global-set-key (kbd "C-q") 'delete-window)

;; Set custom theme path
(setq custom-theme-directory (concat user-emacs-directory "themes"))

(dolist
    (path (directory-files custom-theme-directory t "\\w+"))
  (when (file-directory-p path)
    (add-to-list 'custom-theme-load-path path)))

;;; Appearances
(set-default-font "Inconsolata-16")
(load-theme 'zenburn t)

;;; why custom why
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (discover-my-major yasnippet yaml-mode ssh-config-mode smex smart-mode-line rainbow-mode rainbow-identifiers rainbow-delimiters python-environment puppet-mode projectile paredit paradox otp nginx-mode morlock markdown-mode magit js2-mode ioccur ido-vertical-mode ido-ubiquitous httpcode htmlize gitignore-mode gitconfig-mode gist fringe-helper flycheck flx-ido fill-column-indicator expand-region epc dockerfile-mode diminish csv-mode crontab-mode buffer-move browse-kill-ring auto-complete ack-and-a-half ace-jump-mode ac-dabbrev))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
