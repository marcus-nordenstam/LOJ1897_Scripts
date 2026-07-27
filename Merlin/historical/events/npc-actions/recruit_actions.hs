; ----------------------------------------------------------------------------
; recruit_actions - the clerical WRITE family of the labour market (the thinks
; live in recruit_think.hs). Every act here is PURE PHYSICAL EFFECT: pen changes
; paper (a document appears, a row is appended, letters land in mail piles, a
; posting comes off the board) and the outcome is stamped - NOTHING ELSE. All
; recruiter bookkeeping (posted / recorded / heard-copy ends) lives in the
; npc-think rules, gated on (did-succeed {act /past}) or on reading the paper
; the act produced. An org is a mental-only object and never an act participant;
; every participant below is paper or people. Writing CONTENT is composed from
; the writer's own beliefs (the letter-codec rule); the ops only encode.
; ----------------------------------------------------------------------------

; Write the job advert onto the parish board. The org's articles (?art - paper)
; are the act's target: the advert copies the workplace off them and records
; them as its org_record backlink; the post (?jk) rides the aux from
; advertise_post's occupations select.
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

; Write one heard application into the applicants book (created at the desk on
; first use). The row content comes from the recruiter's own heard belief.
(npc-action {@self record_applicant ?cand}
  (duration 10)
  (effects
    (bind {?cand apply_for ?jk})
    ; Branch-scoped binds do not escape an (if), so each arm writes its own row
    ; (the book is found at the desk, or opened fresh on the first application).
    (if (is-entity (believed-located [k job_application] (current-building @self)))
        (then
          (bind (believed-located [k job_application] (current-building @self)) ?appdoc)
          (write-doc-record [k job_application] ?appdoc
              (worker ?cand) (job ?jk) (merit 1)))
        (else
          (create-entity [k job_application]
              (qual location (current-building @self)) (bind ?newdoc))
          (write-doc-record [k job_application] ?newdoc
              (worker ?cand) (job ?jk) (merit 1))))
    (set-outcome {@self record_applicant ?cand} succ)))

; The morning of correspondence: an offer letter to the chosen applicant and a
; rejection to every other, each into their home mail pile (the letters carry
; NAMED facts through the shared letter codec - the reader resolves himself).
; The act's target is the applicants book itself (?appdoc); it closes with the
; round (destroyed - a fresh book next time).
(npc-action {@self send_letters ?appdoc ?win}
  (duration 30)
  (effects
    (for-each-doc-record [k job_application] ?appdoc (worker ?w) (job ?jk)
      (if (= ?w ?win)
          (then (spawn-letter [k letter]
                    (written-msg {?w offered ?jk} signed) (home-of ?w)))
          (else (spawn-letter [k letter]
                    (written-msg {?w rejected ?jk} signed) (home-of ?w)))))
    (destroy-entity ?appdoc)
    (set-outcome {@self send_letters ?appdoc ?win} succ)))

; Enrol the accepted hire on the wage book (?reg - paper, derived by the
; proposing think). The row content comes from the recruiter's own heard belief.
(npc-action {@self enrol ?cand ?reg}
  (duration 10)
  (effects
    (bind {?cand accept_of ?jk})
    (write-doc-record [k employee_register] ?reg
        (worker ?cand) (job ?jk) (level [k trainee]))
    (set-outcome {@self enrol ?cand ?reg} succ)))

; Take a filled posting off the board: the paper is removed, nothing more.
(npc-action {@self take_down ?ad}
  (duration 5)
  (effects
    (destroy-entity ?ad)
    (set-outcome {@self take_down ?ad} succ)))
