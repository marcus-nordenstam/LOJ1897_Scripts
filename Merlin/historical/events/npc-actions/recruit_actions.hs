; ----------------------------------------------------------------------------
; recruit_actions - the clerical WRITE family of the labour market (the thinks
; live in recruit_think.hs). Pen-changes-paper acts; every writing is COMPOSED
; here in .hs (write-doc-record fields / written-msg letters) - the ops only
; encode. Each act reads what it needs off its own act-belief + @self's own
; beliefs, never re-deriving.
; ----------------------------------------------------------------------------

; Post the job advert on the parish board (?board - the act's PHYSICAL target; an
; org has no env entity). The org is re-derived from the actor's own running
; advertise task belief. The post (?jk) was picked by advertise_post's occupations
; select and rides the act-belief's aux; the advert's fields are everything a
; seeker needs (the class floor re-read off the same catalog by job key).
(npc-action {@self post_advert ?board ?jk}
  (duration 20)
  (effects
    (bind {@self advertise ?org})
    (bind (target {?org record}) ?art)
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
    (create-entity [k job_description]
        (qual location (current-building @self)) (bind ?ad))
    (write-doc-record [k job_description] ?ad
        (org_record ?art) (job ?jk) (level [k trainee]) (salary 1)
        (class_floor (lookup occupations job ?jk class_floor [k lower]))
        (workplace ?wp))
    (begin-belief {@self posted ?ad ?org})
    (set-outcome {@self post_advert ?board ?jk} succ)))

; Record one heard application into the applicants book (created at the desk on
; first use). The heard {?cand apply_for <job>} copy is closed once recorded, so
; a later re-application is heard fresh.
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
    (begin-belief {@self recorded ?cand})
    (end-belief {?cand apply_for ?jk})
    (set-outcome {@self record_applicant ?cand} succ)))

; The morning of correspondence: an offer letter to the chosen applicant and a
; rejection to every other, each into their home mail pile (the letters carry
; NAMED facts through the shared letter codec - the reader resolves himself).
; The act's PHYSICAL target is the applicants book itself (?appdoc); it closes
; with the round (destroyed - a fresh book next time).
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

; Enrol the accepted hire on the wage book - and TAKE THE ADVERT DOWN: the
; position is filled, so the posting comes off the board (destroyed) and the
; recruiter's own posted / recorded bookkeeping closes.
(npc-action {@self enrol ?cand}
  (duration 10)
  (effects
    (bind {?cand accept_of ?jk})
    (bind {@self posted ?ad ?org})
    (bind (target {?org record}) ?art)
    (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
    (write-doc-record [k employee_register] ?reg
        (worker ?cand) (job ?jk) (level [k trainee]))
    (end-belief {@self posted ?ad ?org})
    (destroy-entity ?ad)
    (end-belief {?cand accept_of ?jk})
    (end-belief {@self recorded ?cand})
    (set-outcome {@self enrol ?cand} succ)))
