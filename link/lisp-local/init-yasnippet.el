;;; init-yasnippet.el --- Provides yasnippet configs
;-*-Emacs-Lisp-*-
;;
;; Filename: init-yasnippet.el
;; Description:
;; Author: 
;; Maintainer: 
;; Created: 
;; Version: 0.1
;; Last-Updated: 
;;           By: 
;;     Update #: 
;; URL:  
;; Keywords: 
;; Compatibility: 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; Put this in your load path and then:
;; (require 'init-yasnippet)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yasnippet
  :ensure t
  :defer t
  :config
  ;;(yas-reload-all)
  (setq tab-always-indent 'complete)
  (define-key yas-minor-mode-map (kbd "<escape>") 'yas-exit-snippet))

(use-package yasnippet-snippets
  :ensure t
  :defer t)

(provide 'init-yasnippet)
;;; init-yasnippet.el ends here