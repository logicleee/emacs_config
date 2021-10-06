;; (sanityinc/add-subdirs-to-load-path
;;  (expand-file-name "lisp-local/" user-emacs-directory))
;; 
;; (require 'lisp-local/init-evil)
;; (require 'lisp-local/init-evil-org)

;; add custom paths
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "lisp-local" user-emacs-directory))

;; set macOS option and command keys back
(when *is-a-mac*
  (setq mac-command-modifier 'none)
  (setq mac-option-modifier 'meta)
  )


;; converting to use-package 2021
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))


;; Install and require evil mode
(require-package 'evil)
(require 'evil)
(evil-mode 1)

;; evil-leader
(setq evil-leader/in-all-states 1)
(require-package 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-key
  "e"  'find-file
  "t"  'org-time-stamp-inactive
  "s"  'org-download-screenshot
  "y"  'org-download-yank
  "b"  'buffer-menu-other-window
  "+"  'text-scale-increase
  "-"  'text-scale-decrease
  )
;; (evil-leader/set-key-for-mode 'org "j" 'org-agenda-goto-calendar)

;; BEGIN org-mode config
(setq org-directory "~/Dropbox/org")
(setq org-agenda-files '("~/org/"))
(setq org-agenda-files (quote ("~/org/")))
(setq org-archive-location (concat org-directory "/../org-zarchive/.zarchive.org::"))
(setq org-refile-allow-creating-parent-nodes 'confirm)
(setq org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5)))
(setq org-refile-use-outline-path 'file)

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (define-key org-agenda-mode-map (kbd "g")
              'org-agenda-goto-date)
            (define-key org-agenda-mode-map (kbd "j")
              'org-agenda-next-item)
            (define-key org-agenda-mode-map (kbd "k")
              'org-agenda-previous-item)
            (define-key org-agenda-mode-map (kbd "n")
              'org-agenda-next-date-line)
            (define-key org-agenda-mode-map (kbd "p")
              'org-agenda-previous-date-line)
            (define-key org-agenda-mode-map (kbd "u")
              'org-agenda-undo)

            ))


(when (maybe-require-package 'org-bullets)
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;; END org-mode config


;; START change export path
;; https://emacs.stackexchange.com/questions/3985/make-org-mode-export-to-beamer-keep-temporary-files-out-of-the-current-directory/7989#7989
(defvar org-export-output-directory-prefix "export_" "prefix of directory used for org-mode export")

(defadvice org-export-output-file-name (before org-add-export-dir activate)
  "Modifies org-export to place exported files in a different directory"
  (when (not pub-dir)
    (setq pub-dir (concat org-export-output-directory-prefix (substring extension 1)))
    (when (not (file-directory-p pub-dir))
      (make-directory pub-dir))))
;; END change export path

;; evil+org mode config
(evil-define-key 'normal org-mode-map "t" 'org-todo )

(add-hook 'org-mode-hook
          (lambda ()
	    (setq-local my-timer
		        (run-with-idle-timer 1 t
					     (lambda ()
					       (when (and (eq major-mode 'org-mode)
						          (and evil-state
							       (not (eq evil-state 'insert)))
						          (buffer-file-name)
						          (buffer-modified-p))
					         (save-buffer)))))
	    ))

(eval-when-compile 
  (add-to-list 'load-path "~/.emacs.d/lisp-local")
  (require 'init-colorscheme)
  (require 'init-org-capture-templates)
  (require 'init-jade-mode)
  (require 'init-datefuncs)
  (require 'init-evil-org)
  (require 'init-org-download)
  (require 'init-yasnippet)
  )


;;; 80 x 50 window size
(setq default-frame-alist '((width . 80) (height . 50)))
(desktop-save-mode 0)

(provide 'init-local)
