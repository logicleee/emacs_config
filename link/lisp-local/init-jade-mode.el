;; BEGIN init-jade-mode

;;; Code:
(add-to-list 'load-path "~/.emacs.d/site-lisp/jade-mode")
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl\\'" . sws-mode))


;; END
(provide 'init-jade-mode)
;;; init-jade-mode.el ends here
