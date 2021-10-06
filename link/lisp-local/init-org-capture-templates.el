;; update org capture templates
;; BEGIN org-mode capture templates

;;; Code:

(defvar org-default-notes-file "~/org/_gtd.org")
(setq org-capture-templates
      `(("t" "todo" entry
         (file+headline "~/org/_refile-term.org" "INBOX") ;
         (file "~/org/templates/todo.org") :clock-resume t)
        ("r" "Reading List" entry
         (file "~/org/p-reading-list.org")
         (file "~/org/templates/reading-list.org"))
        ("j" "Job Application" entry
         (file "~/org/r-job-app-log-2021.org")
         (file "~/org/templates/job-app.org"))
        ("c" "Call Log Entry" entry
         (file+headline "~/org/_refile-term.org" "INBOX") ;
         (file "~/org/templates/call-log.org"))
        ("o" "Journal Entry" entry
         (file "~/org/.org-journal/.journal.org")
         (file "~/org/templates/journal.org"))
  	("d" "Review: Daily Review" entry
  	 (file+datetree "~/org/r-gtd-reviews-daily.org")
  	 (file "~/org/templates/review-daily-template.org") :tree-type week)
  	("w" "Review: Weekly Review" entry
  	 (file+datetree "~/org/r-gtd-reviews-weekly.org")
  	 (file "~/org/templates/review-weekly-template.org") :tree-type week)
        ))

;; END org-mode capture templates

(provide 'init-org-capture-templates)
