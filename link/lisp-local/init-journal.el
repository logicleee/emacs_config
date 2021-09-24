;; BEGIN org-mode journal
;; LINK: http://www.howardism.org/Technical/Emacs/journaling-org.html
;;; Code:


(defun get-journal-file-today ()
  "Return filename for today's journal entry."
  (let ((daily-name (format-time-string "%Y-%m-%d")))
    (expand-file-name (concat "~/Dropbox/.org-journal/journal_" daily-name ".org"))))

(defun journal-file-today ()
  "Create and load a journal file based on today's date."
  (interactive)
  (find-file (get-journal-file-today)))

(global-set-key (kbd "C-c f j") 'journal-file-today)

(defun journal-file-insert ()
  "Insert's the journal heading based on the file's name."
  (interactive)
  (when (string-match "\\(20[0-9][0-9]\\)\\([0-9][0-9]\\)\\([0-9][0-9]\\)"
                      (buffer-name))
    (let ((year  (string-to-number (match-string 1 (buffer-name))))
          (month (string-to-number (match-string 2 (buffer-name))))
          (day   (string-to-number (match-string 3 (buffer-name))))
          (datim nil))
      (setq datim (encode-time 0 0 0 day month year))
      (insert (format-time-string
               "#+TITLE: Journal Entry- %Y-%b-%d (%A)\n\n" datim)))))


;;(add-hook 'find-file-hook 'auto-insert)
;;(add-to-list 'auto-insert-alist '(".*/journal_[0-9]*.org$" . journal-file-insert))

(setq org-capture-templates
      (append org-capture-templates
              '(("j" "Journal Note"
                 entry (file (get-journal-file-today))
                 "* Event: %?\n\n  %i\n\n  From: %a"
                 :empty-lines 1)
                )))

;; END org-mode journal
(provide 'lisp-local/init-journal)
