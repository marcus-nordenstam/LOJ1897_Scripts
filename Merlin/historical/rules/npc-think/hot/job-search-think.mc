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
  (role @self (not (spatial @self building ?board)))
  (when (and (job-seeker @self)
             (latch-eval (chance 0.3))))
  (utility errand)
  (effects (maintain-proposal {@self enter ?board})))

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
  (effects
           (maintain-proposal {@self find-building [k building church] ?rg})))

; --- at the board, READ each advert not yet read: adopt its {?org display-ad ?job} +
; {?org workplace ?wp} sentences (the physical knowledge channel - no doc-record pull).
; The advert carries the org's OWN sentence, so the reader ends up holding the same fact
; the recruiting officer does, about the same post.
(npc-think seek_read_board
  ; HOT, not cooldown: standing beside an unread notice is an opportunity, and the wake that
  ; admits it (the notice perceived, the room entered) would be dropped by a cooling rule.
  (rng-stream employment)
  (role @self -{@self job ?}
              -{@self apply-for ? ? /pres})
  (role ?ad [k job-description] (spatial ?ad co-located @self)
                                -{@self READ ?ad /succ})
  (utility errand)
  (effects (maintain-proposal {@self READ ?ad})))

; --- a posting @self has READ, qualifies for (class-floor derived from the post's own
; kind), and never APPLIED FOR -> begin ONE apply-for, keyed on the job-kind + the concrete
; WORKPLACE the advert named. apply-for's /succ is the applied record: one application per
; post, ever; the verdict comes back by letter (take_up_offer below). Picked in DAYTIME only
; (LATCHED at the pick: a plain hour test is re-read on hold and would withdraw the errand
; at dusk): the application is an hour's errand, and a night pick would sit until morning.
(npc-think seek_apply_pick
  ; ONE application at a time: the lock admits a single activation, held for as long as
  ; the maintained apply-for runs; it releases when the activation retires (hired, or the
  ; application concluded).
  (lock-rule)
  (rng-stream employment)
  (role @self -{@self job ?})
  (role ?org {?org display-ad ?job}
             {?org workplace ?wp}
             (select (score 1) (policy roulette)))
  (when (and (latch-eval (and (>= (now-hour) 8) (<= (now-hour) 17)))
             (kind ?job): ?jk
             (if (table-match occupations job ?jk class-floor ?cf0) (then ?cf0) (else [k lower])): ?cf
             (class-at-least @self ?cf)
             -{@self apply-for ?jk ?wp /succ}))
  (utility errand)
  (effects
           (maintain-proposal {@self apply-for ?jk ?wp})))

; --- an OFFER letter @self has read (the home post's daily read-mail round) answers the one
; application in flight: take up the post it was for. The letter is a typed signal (its KIND
; is the verdict); which post it answers is @self's own applied record.
(npc-think take_up_offer
  (role ?ltr [k offer-letter] {@self READ ?ltr /ever})
  (role @self {@self apply-for ?jk ?wp /succ}
              -{@self take-up-post ?jk ?wp /succ})
  (utility errand)
  (effects (maintain-proposal {@self take-up-post ?jk ?wp})))

; === The apply-for TASK (gohome / write / send / posted) lives in
; npc-tasks/apply-for-task.mc; take-up-post in npc-tasks/take-up-post-task.mc. The verdict
; letter itself is read by the daily read-mail round (read-mail-think.mc).
