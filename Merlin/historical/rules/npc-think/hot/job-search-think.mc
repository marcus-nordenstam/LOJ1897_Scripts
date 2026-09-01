; ----------------------------------------------------------------------------
; job_search - the WORKER side of the labour market (recruiter side: recruit_think.hs;
; clerical acts: recruit_actions.hs).
;
; The whole hunt is the `apply-for <job> <org-articles>` TASK and its OUTCOME:
;   running   = applied / in progress (one at a time)
;   succ      = took the job (hired)
;   fail      = rejected -> the /fail conclusion is the re-application memory
;
; A jobless working-age adult who needs work (wealth gate) and is not already applying
; goes to the parish board, picks an advert whose job+org he has not already FAILED, and
; begins ONE apply-for. Sub-tasks write + mail the application. The verdict arrives as a
; TYPED letter read (held) in the morning post: with one apply-for in flight, the letter's
; KIND alone is the verdict - offer-letter -> take up the post (apply-for /succ),
; rejection-letter -> apply-for fail. Reading requires HOLDING the paper.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- pre-commit: visit the parish board while jobless and not already applying -----
; Two cases, complementary on whether @self KNOWS a church: he heads to one he knows, or
; he searches the region for one (the find-building task walks the unobserved structures).
(npc-think seek_board_visit
  (cooldown 1 m)
  (rng-stream employment)
  (role @self -{@self job ?}
              -{@self apply-for ? ? /pres})
  (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))
  (when (and (job-seeker @self)
             (not (spatial @self building ?board))
             (latch-eval (chance 0.3))))
  (utility errand)
  (effects (debug-print "JS_BOARDGO") (maintain-proposal {@self enter ?board})))

(npc-think seek_board_find
  (cooldown 1 m)
  (rng-stream employment)
  (role @self -{@self job ?}
              -{@self apply-for ? ? /pres})
  (no-role [k building church])
  ; The search's own /fail act-memory is the "this region has no church" record - it stops
  ; the hunt re-proposing forever once find-building has walked every structure.
  (when (and (job-seeker @self)
             -{@self find-building [k building church] ? /fail}
             (current-region @self): ?rg))
  (utility errand)
  (effects (debug-print "JS_BOARDFIND rg=?rg")
           (maintain-proposal {@self find-building [k building church] ?rg})))

; --- at the board, READ each advert not yet read: adopt its {?org vacancy ?jk} +
; {?org workplace ?wp} sentences (the physical knowledge channel - no doc-record pull).
(npc-think seek_read_board
  (cooldown 1 m)
  (rng-stream employment)
  (role @self -{@self job ?}
              -{@self apply-for ? ? /pres})
  (role ?ad [k job-description] (spatial ?ad co-located @self)
                                -{@self READ ?ad /succ})
  (utility errand)
  (effects (debug-print "JS_READ") (maintain-proposal {@self READ ?ad})))

; --- a vacancy @self has READ, qualifies for (class-floor derived from the role), and
; never FAILED -> begin ONE apply-for, keyed on the job-kind + the concrete WORKPLACE
; the advert named (the shared anchor every sub-task re-derives the rest from).
(npc-think seek_apply_pick
  ; ONE application at a time: the lock admits a single activation; it releases when
  ; the activation retires (the /pres role filter falls at promotion), and the /pres
  ; gate then bars re-admission until the apply-for concludes.
  (lock-rule)
  (rng-stream employment)
  (role @self -{@self job ?}
              -{@self apply-for ? ? /pres})
  (role ?org {?org vacancy ?jk}
             (select (score 1) (policy roulette)))
  (when (and {?org workplace ?wp}
             (if (table-match occupations job ?jk class-floor ?cf0) (then ?cf0) (else [k lower])): ?cf
             (class-at-least @self ?cf)
             -{@self apply-for ?jk ?wp /fail}))
  (utility errand)
  (effects (debug-print "JS_PICK jk=?jk")
           (begin-proposal {@self apply-for ?jk ?wp})))

; === The apply-for TASK (gohome / write / send / await_verdict / take_up / rejected /
; succeeded) lives in npc-tasks/apply-for-task.hs. The take-up-post sub-task lives in
; npc-tasks/take-up-post-task.hs. Both are begun from the seek_apply_pick / verdict tries.
; The verdict letter itself is read by the daily read-mail round (read_mail_think.hs).
