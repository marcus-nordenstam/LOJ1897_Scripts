; ----------------------------------------------------------------------------
; recruit_actions - the clerical WRITE family of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Every act is pen-changes-paper: a document
; appears, is filed / pulled / stamped, a letter lands in a mail pile, a posting comes off
; the board. An org is a mental-only object and never an act participant - every
; participant is paper or people.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; RECRUITER: write the job advert onto the parish board. The org's articles (?art) are the
; act's target; the advert copies the workplace off them and backlinks them as org_record.
(npc-action {@self post_advert ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k job_description]
        (qual location (current-building @self)) (bind ?ad))
    (write-doc-record [k job_description] ?ad
        (org_record ?art) (job ?jk) (level [k trainee]) (salary 1)
        (class_floor (lookup occupations job ?jk class_floor [k lower]))
        (workplace ?wp))
    (set-outcome {@self post_advert ?art ?jk} succ)))

; SEEKER: write the application paper (left on the workplace grid; af_send mails it). It
; copies the post / org / workplace off the org's articles (?art) + the picked job (?jk).
(npc-action {@self prepare_application ?art ?jk}
  (duration 20)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k application]
        (qual location (current-building @self)) (bind ?app))
    (write-doc-record [k application] ?app
        (applicant @self) (job ?jk) (org_record ?art) (workplace ?wp))
    (set-outcome {@self prepare_application ?art ?jk} succ)))

; SEEKER: mail the finished application into the org's back-office inbox (de-grids it into
; the mail pile). The paper's own workplace field names the premises.
(npc-action {@self submit_application ?app}
  (duration 10)
  (effects
    (read-doc-record [k application] ?app (workplace ?wp))
    (file-in-stack ?app (room-of ?wp [k back_office]))
    (set-outcome {@self submit_application ?app} succ)))

; RECRUITER: ONE sweep of the back-office inbox. Offer the TOP applicant (an offer_letter
; to his home), reject every other (a rejection_letter to theirs), and DESTROY every
; application so none accumulate. The seeker's side rides HIS apply_for task outcome - the
; letter's KIND is the whole verdict.
(npc-action {@self gather_applications ?art}
  (duration 30)
  (effects
    (debug-print "RC_SWEPT")
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (bind (room-of ?wp [k back_office]) ?office)
    (bind (attr (mail-pile ?office) top) ?top)
    (for-each ?app (attr-values (mail-pile ?office) items [k application])
      (do
        (read-doc-record [k application] ?app (applicant ?w))
        (if (= ?app ?top)
            (then
              (debug-print "RC_OFFER")
              (create-entity [k offer_letter]
                  (qual location (mail-space (home-of ?w))) (bind ?ol))
              (file-in-stack ?ol (mail-space (home-of ?w))))
            (else
              (create-entity [k rejection_letter]
                  (qual location (mail-space (home-of ?w))) (bind ?rl))
              (file-in-stack ?rl (mail-space (home-of ?w)))))
        (destroy-entity ?app)))
    (set-outcome {@self gather_applications ?art} succ)))

; SEEKER: take up the offered post - write his own row onto the wage book (?jk from the
; still-running apply_for). Reading his row back (tup_read_book) realizes employment.
(npc-action {@self take_post ?art ?jk}
  (duration 15)
  (effects
    (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
    (write-doc-record [k employee_register] ?reg
        (worker @self) (job ?jk) (level [k trainee]))
    (set-outcome {@self take_post ?art ?jk} succ)))

; RECRUITER: take a filled posting off the board - the paper is removed.
(npc-action {@self take_down ?ad}
  (duration 5)
  (effects
    (destroy-entity ?ad)
    (set-outcome {@self take_down ?ad} succ)))
