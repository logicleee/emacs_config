;; Install and require evil mode
(require-package 'evil)
(require 'evil)
(evil-mode 1)

(require-package 'evil-leader)
(evil-leader/set-key
 "e"  'find-file
 "t"  'org-time-stamp-inactive
 "b"  'buffer-menu-other-window)


(provide 'lisp-local/init-evil)
