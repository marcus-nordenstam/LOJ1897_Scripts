; ----------------------------------------------------------------------------
; job_search - the WORKER side of the labour market (the recruiter side lives in
; recruit_think.hs; the shared read action in read_action.hs).
;
;   GOAL {@self employed}      the STATE the seeker wants (want_work mints it;
;                              the falling edge of joblessness ends it).
;   TASK seek_work             the hunt; its running belief is the context every
;                              rung keys on. Rungs: visit the parish board, read
;                              unread adverts, choose the best unapplied advert.
;   TASK apply ?ad             one application to one advert: go to the
;                              workplace, SAY the application (with skills - the
;                              room hears; the recruiter records it).
;   TASK take_up_post ?ad      the offer came by letter: return, SAY acceptance,
;                              then READ the wage book - employment is REALIZED
;                              by reading one's own row (hire-beliefs), never by
;                              any injected belief.
;
; Every cross-NPC hop is a say, a letter or a public document - no mind reads.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the decision: a jobless working-age adult wants to be employed -----------
(npc-think want_work
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (not (believes {@self job.salary ?})))
  ; The staggered take-up: a third of the jobless start hunting in any given
  ; evaluation round, instead of every jobless adult stampeding the same board on
  ; the same day. latch-eval locks a PASSED roll for the bout - the hold re-check
  ; must not re-roll a standing goal away hours after minting it.
  (when (and (>= (years-old @self) 16)
             (<= (years-old @self) 55)
             (not (= (situation @self repute) [k scandalous]))
             (latch-eval (chance 0.3))))
  (effects       (debug-print "TRACE-WANTWORK begin-employed-goal")
                 (begin-goal {@self employed}))
  ; The minter owns the end: once employed the jobless gate falls and the goal ends.
  (cease-effects (end-goal {@self employed})))

; --- the hunt task, proposed off the goal -------------------------------------
(npc-think seek_work_root
  (goal {@self employed})
  (utility 70)
  (effects (maintain-proposal {@self seek_work})))

; --- rung: visit the parish board (monthly while hunting) ---------------------
(npc-think seek_board_visit
  (cooldown 1 m)
  (role @self (believes {@self seek_work}))
  (when (and (bind (find-building [k building church]) ?board)
             (not (in-building ?board))))
  (utility 71)
  (effects (debug-print "TRACE-BOARDVISIT board=?board")
           (maintain-proposal {@self enter ?board})))

; --- rung: read every unread advert at the board -------------------------------
(npc-think seek_read_advert
  (role @self (believes {@self seek_work}))
  (role ?ad [k job_description]
            (not (believes {?ad advert_job ?}))
            (select (policy first-match)))
  (when (co-present @self ?ad))
  (utility 72)
  (effects (maintain-proposal {@self read ?ad})))

; POST-ACT: the advert was read (eyes on paper) -> its record fields become the
; seeker's advert_* beliefs ON the advert object (what choose_application and
; the apply/take-up rungs need). The read act itself learns nothing.
(npc-think advert_learn
  (role @self (believes {@self seek_work}))
  (role ?ad [k job_description]
            (not (believes {?ad advert_job ?})))
  (when (and (believes {@self read ?ad /succ})
             (read-doc-record [k job_description] ?ad
                 (org_record ?art) (job ?jk) (level ?lvl) (salary ?sal)
                 (class_floor ?cf) (workplace ?wp))))
  (effects
    (begin-belief {?ad advert_org ?art})
    (begin-belief {?ad advert_job ?jk})
    (begin-belief {?ad advert_level ?lvl})
    (begin-belief {?ad advert_pay ?sal})
    (begin-belief {?ad advert_floor ?cf})
    (begin-belief {?ad advert_workplace ?wp})))

; --- decision: choose the best known advert not yet applied to -----------------
; The (select) argmax picks ONE (best pay); the applied dedup rotates the choice
; on the next pass, so the seeker holds at most one application in flight.
(npc-think choose_application
  (cooldown 7 d)
  (rng-stream employment)
  (role @self (believes {@self seek_work}))
  (role ?ad [k job_description]
            (believes {?ad advert_job ?jk})
            (believes {?ad advert_floor ?cf})
            (not (believes {@self applied ?ad}))
            (select (score (target-or ?ad advert_pay 0)) (policy argmax)))
  (when (class-at-least @self ?cf))
  (utility 73)
  (effects (maintain-proposal {@self apply ?ad})))

; --- the application task rungs -------------------------------------------------
; Calls happen in BUSINESS HOURS - the recruit_staff holder is on shift then, so
; the say lands on working ears (a 2 AM declaration to an empty counter is heard
; by nobody who can act on it).
(npc-think apply_go
  (role @self (believes {@self apply ?ad}))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 16)
             (believes {?ad advert_workplace ?wp})
             (not (in-building ?wp))))
  (utility 74)
  (effects (debug-print "TRACE-APPLYGO wp=?wp ad=?ad")
           (maintain-proposal {@self enter ?wp})))

; SAY the application to whoever is at the counter - the speech sound reaches
; every co-present ear, so the recruiter hears it when on shift. The utterance
; carries the post applied for AND the applicant's skills (all relevant info,
; so the recruiter never has to guess).
(npc-think apply_speak
  (role @self (believes {@self apply ?ad}))
  (role ?p (any_human ?p) (select (policy first-match)))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 17)
             (believes {?ad advert_workplace ?wp})
             (in-building ?wp)
             (co-present @self ?p)
             (believes {?ad advert_job ?jk})))
  (utility 75)
  ; `signed`: the applicant STATES THEIR NAME - a stranger recruiter must be able
  ; to write the applicant into his book and address the decision letter.
  (effects (debug-print "TRACE-APPLYSPEAK to=?p jk=?jk wp=?wp")
           (maintain-proposal
             {@self say_to (utterable-msg (to ?p)
                             {@self apply_for ?jk}
                             (every-ongoing-belief {@self skilled_in ?})
                             signed)
                    ?p})))

; Saying is believing: the spoken application shows up as @self's own
; {@self apply_for ?jk} - convert it to the per-advert dedup and clear it.
; The applied mint drops choose_application's not-applied filter, which
; withdraws the apply task (its proposer's falling edge).
(npc-think apply_done
  (role @self (believes {@self apply ?ad}))
  (when (and (believes {?ad advert_job ?jk})
             (believes {@self apply_for ?jk})))
  (effects
    (debug-print "TRACE-APPLYDONE ad=?ad jk=?jk")
    (begin-belief {@self applied ?ad})
    (end-belief {@self apply_for ?jk})))

; --- the offer letter arrived (read at home) -> take up the post ---------------
(npc-think offer_pickup
  (role @self (believes {@self seek_work})
              (believes {@self offered ?jk}))
  (role ?ad [k job_description]
            (believes {@self applied ?ad})
            (believes {?ad advert_job ?adjk})
            (select (policy first-match)))
  (when (= ?adjk ?jk))
  (utility 76)
  (effects (debug-print "TRACE-OFFERPICKUP jk=?jk ad=?ad")
           (maintain-proposal {@self take_up_post ?ad})))

(npc-think tup_go
  (role @self (believes {@self take_up_post ?ad}))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 16)
             (believes {?ad advert_workplace ?wp})
             (not (in-building ?wp))))
  (utility 77)
  (effects (maintain-proposal {@self enter ?wp})))

(npc-think tup_accept_speak
  (role @self (believes {@self take_up_post ?ad})
              (not (believes {@self accept_of ?})))
  (role ?p (any_human ?p) (select (policy first-match)))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 17)
             (believes {?ad advert_workplace ?wp})
             (in-building ?wp)
             (co-present @self ?p)
             (believes {?ad advert_job ?jk})))
  (utility 78)
  (effects (maintain-proposal
             {@self say_to (utterable-msg (to ?p) {@self accept_of ?jk} signed) ?p})))

; After accepting, READ the wage book (the recruiter enrols on hearing the
; acceptance; the row appears; reading it yields {@self enrolled ...}).
(npc-think tup_read_book
  (role @self (believes {@self take_up_post ?ad})
              (believes {@self accept_of ?}))
  (role ?reg [k employee_register] (select (policy first-match)))
  (when (co-present @self ?reg))
  (utility 79)
  (effects (maintain-proposal {@self read ?reg})))

; POST-ACT: the wage book was read -> the reader's OWN row (if any) becomes
; {@self enrolled <job> <level>}, the employment_realized trigger.
(npc-think register_learn
  (role @self (believes {@self take_up_post ?ad})
              (believes {@self accept_of ?}))
  (role ?reg [k employee_register] (select (policy first-match)))
  (when (and (believes {@self read ?reg /succ})
             (read-doc-record [k employee_register] ?reg
                 (find worker @self) (job ?myjk) (level ?mylvl))))
  (effects (begin-belief {@self enrolled ?myjk ?mylvl})))

; Employment REALIZED: his own wage-book row read back -> the full job object
; (org / salary / level / since / shifts) via the shared hire-beliefs macro.
; job.salary now holds -> want_work's falling edge ends the employed goal and
; the whole hunt collapses.
(npc-think employment_realized
  (role @self (believes {@self take_up_post ?ad})
              (believes {@self enrolled ?jk ?lvl}))
  (when (believes {?ad advert_org ?art}))
  (effects
    (hire-beliefs ?art ?jk ?lvl)
    (end-belief {@self enrolled ?jk ?lvl})
    (end-belief {@self offered ?jk})
    (end-belief {@self accept_of ?jk})))

; --- the morning post: read unread letters at home ------------------------------
(npc-think read_letters
  (role ?letter [k letter]
                (not (believes {@self read ?letter}))
                (select (policy first-match)))
  (when (co-present @self ?letter))
  (utility 72)
  (effects (maintain-proposal {@self read ?letter})))
