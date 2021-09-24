;; BEGIN init-datefuncs

(defun now ()
  "Insert timestamp"
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "[%F %R] " )))

(defun today ()
  "Insert today's date"
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%F")))

(defun wkNum ()
  "Insert year & week string"
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "wk%Y%g ")))

(provide 'init-datefuncs)
;;; init-datefuncs.el ends here
