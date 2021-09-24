;; update org capture templates
;; BEGIN org-mode capture templates

;;; Code:

(defvar org-default-notes-file "~/org/_gtd.org")
(setq org-capture-templates
      `(("t" "todo" entry
         (file+headline "~/org/_refile-term.org" "INBOX") ;
         (file "~/Dropbox/org-capture-templates/todo.org") :clock-resume t)
        ("r" "Reading List" entry
         (file "~/org/p-reading-list.org")
         (file "~/Dropbox/org-capture-templates/reading-list.org"))
        ("j" "Job Application" entry
         (file "~/Dropbox/org/r-job-app-log-2019.org")
         (file "~/Dropbox/org-capture-templates/job-app.org"))
        ("c" "Call Log Entry" entry
         (file+headline "~/org/_refile-term.org" "INBOX") ;
         (file "~/Dropbox/org-capture-templates/call-log.org"))
        ("o" "Journal Entry" entry
         (file "~/Dropbox/.org-journal/.journal.org")
         (file "~/Dropbox/org-capture-templates/journal.org"))
  	("d" "Review: Daily Review" entry
  	 (file+datetree "~/org/r-gtd-reviews-daily.org")
  	 (file "~/Dropbox/org-capture-templates/review-daily-template.org") :tree-type week)
  	("w" "Review: Weekly Review" entry
  	 (file+datetree "~/org/r-gtd-reviews-weekly.org")
  	 (file "~/Dropbox/org-capture-templates/review-weekly-template.org") :tree-type week)
        ))

;; END org-mode capture templates

(provide 'init-org-capture-templates)
