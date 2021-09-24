;; update org download config
;; BEGIN org download config

;;; Code:

(require-package 'org-download)
(require 'org-download)
(setq-default org-download-image-dir "~/Dropbox/org-media")
(setq-default org-download-screenshot-method "screencapture")
(setq-default org-download-display-inline-images t)
(setq-default org-download-heading-lvl nil)
(if (equal system-type 'darwin)
	(setq org-download-screenshot-method "/usr/sbin/screencapture -i %s"))
(add-hook 'org-mode-hook 'org-download-enable)

;; ;; Drag-and-drop to `dired`
;; (add-hook 'dired-mode-hook 'org-download-enable)

(provide 'init-org-download)
;;; init-org-download.el ends here
