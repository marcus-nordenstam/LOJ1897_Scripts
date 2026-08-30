; ----------------------------------------------------------------------------
; job_search - the WORKER side of the labour market (recruiter side: recruit_think.hs;
; clerical acts: recruit_actions.hs).
;
; The whole hunt is the `apply_for <job> <org-articles>` TASK and its OUTCOME:
;   running   = applied / in progress (one at a time)
;   succ      = took the job (hired)
;   fail      = rejected -> the /fail conclusion is the re-application memory
;
; A jobless working-age adult who needs work (wealth gate) and is not already applying
; goes to the parish board, picks an advert whose job+org he has not already FAILED, and
; begins ONE apply_for. Sub-tasks write + mail the application. The verdict arrives as a
; TYPED letter read (held) in the morning post: with one apply_for in flight, the letter's
; KIND alone is the verdict - offer_letter -> take up the post (apply_for /succ),
; rejection_letter -> apply_for fail. Reading requires HOLDING the paper.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- pre-commit: visit the parish board while jobless and not already applying -----
(npc-think seek_board_visit
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (not {@self job ?})
              (not {@self apply_for ? ? /pres}))
  (when (and (>= (years-old @self) 16)
             (<= (years-old @self) 55)
             (!= (any {@self repute ?}).target [k scandalous])
             ; wealth gate: the independently rich do not seek waged work; a seeker with
             ; no wealth belief yet is treated as needing work (the (and ..) is false).
             (not (and (any {@self wealth ?w}) (>= ?w (seek_job_wealth_ceiling))))
             (find-building [k building church]): ?board
             (not (spatial @self building ?board))
             (latch-eval (chance 0.3))))
  (utility errand)
  (effects (debug-print "JS_BOARDGO") (maintain-proposal {@self enter ?board})))

; --- at the board, READ each advert not yet read: adopt its {?org vacancy ?jk} +
; {?org workplace ?wp} sentences (the physical knowledge channel - no doc-record pull).
(npc-think seek_read_board
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (not {@self job ?})
              (not {@self apply_for ? ? /pres}))
  (role ?ad [k job_description] (spatial ?ad co-located @self)
                                (none {@self READ ?ad /succ}))
  (utility errand)
  (effects (debug-print "JS_READ") (maintain-proposal {@self READ ?ad})))

; --- a vacancy @self has READ, qualifies for (class-floor derived from the role), and
; never FAILED -> begin ONE apply_for, keyed on the job-kind + the concrete WORKPLACE
; the advert named (the shared anchor every sub-task re-derives the rest from).
(npc-think seek_apply_pick
  ; ONE application at a time: the lock admits a single activation; it releases when
  ; the activation retires (the /pres role filter falls at promotion), and the /pres
  ; gate then bars re-admission until the apply_for concludes.
  (lock-rule)
  (rng-stream employment)
  (role @self (not {@self job ?})
              (not {@self apply_for ? ? /pres}))
  (role ?org {?org vacancy ?jk}
             (select (score 1) (policy roulette)))
  (when (and {?org workplace ?wp}
             (if (table-match occupations job ?jk class_floor ?cf0) (then ?cf0) (else [k lower])): ?cf
             (class-at-least @self ?cf)
             (none {@self apply_for ?jk ?wp /fail})))
  (utility errand)
  (effects (debug-print "JS_PICK jk=?jk")
           (begin-proposal {@self apply_for ?jk ?wp})))

; === The apply_for TASK (gohome / write / send / await_verdict / take_up / rejected /
; succeeded) lives in npc-tasks/apply_for-task.hs. The take_up_post sub-task lives in
; npc-tasks/take_up_post-task.hs. Both are begun from the seek_apply_pick / verdict tries.
; The verdict letter itself is read by the daily read_mail round (read_mail_think.hs).
