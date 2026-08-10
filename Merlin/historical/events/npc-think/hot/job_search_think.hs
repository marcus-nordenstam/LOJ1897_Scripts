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
; KIND alone is the verdict - offer_letter -> take up the post (apply_for succ),
; rejection_letter -> apply_for fail. Reading requires HOLDING the paper.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- pre-commit: visit the parish board while jobless and not already applying -----
(npc-think seek_board_visit
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (not {@self job.salary ?})
              (not {@self apply_for ? ? /pres}))
  (when (and (>= (years-old @self) 16)
             (<= (years-old @self) 55)
             (not (= (situation @self repute) [k scandalous]))
             ; wealth gate: the independently rich do not seek waged work; a seeker with
             ; no wealth belief yet is treated as needing work (the (and ..) is false).
             (not (and (believes {@self wealth ?w}) (>= ?w (seek_job_wealth_ceiling))))
             (find-building [k building church]): ?board
             (not (in-building ?board))
             (latch-eval (chance 0.3))))
  (utility 71)
  (effects (debug-print "JS_BOARDGO") (maintain-proposal {@self enter ?board})))

; --- pre-commit: at the board, pick an eligible advert never failed -> begin apply_for
; The advert doc carries job / org / class-floor; the running apply_for keeps only the
; job-kind + the org's articles (the durable anchors), and every sub-task re-derives the
; rest from ?art on demand.
(npc-think seek_apply_pick
  ; ONE application at a time: the lock admits a single activation; it releases when
  ; the activation retires (the /pres role filter falls at promotion), and the /pres
  ; gate then bars re-admission until the apply_for concludes.
  (lock-rule)
  (rng-stream employment)
  (role @self (not {@self job.salary ?})
              (not {@self apply_for ? ? /pres}))
  (role ?ad [k job_description] (select (score 1) (policy roulette)))
  (when (and (co-present @self ?ad)
             (read-doc-record [k job_description] ?ad (job ?jk) (org_record ?art) (class_floor ?cf))
             (class-at-least @self ?cf)
             (none {@self apply_for ?jk ?art /fail})))
  (utility 73)
  (effects (debug-print "JS_PICK jk=?jk")
           (begin-proposal {@self apply_for ?jk ?art})))

; === apply_for sub-tasks: write + mail the application =============================
; The "already prepared" signal is the prepare_application ACT's own /succ outcome, keyed
; on THIS apply_for's (articles, job) - so it gates the go/write rungs off after one paper,
; and being per-(art,jk) it never leaks to a later apply_for. The finished paper sits on
; the grid at the workplace (writing needs no hand; only READING needs holding) until
; af_send mails it into the inbox.

; go to the org's workplace to write + mail
(npc-think af_go
  (task {@self apply_for ?jk ?art})
  (when (and (none {@self prepare_application ?art ?jk /succ})
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (not (in-building ?wp))))
  (utility 74)
  (effects (maintain-proposal {@self enter ?wp})))

; at the workplace in business hours: write the application (created on the grid)
(npc-think af_write
  (task {@self apply_for ?jk ?art})
  (when (and (none {@self prepare_application ?art ?jk /succ})
             (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building ?wp)
             (>= (now-hour) 9)
             (<= (now-hour) 16)))
  (utility 75)
  (effects (maintain-proposal {@self prepare_application ?art ?jk})))

; the finished paper is co-present (on the workplace grid): mail it into the inbox. Once
; filed it de-grids into the pile, so it is no longer co-present and this rung falls.
(npc-think af_send
  (task {@self apply_for ?jk ?art})
  (role ?app [k application] (select (policy first-match)))
  (when (and (co-present @self ?app)
             (read-doc-record [k application] ?app (find applicant @self))))
  (utility 76)
  (effects (debug-print "JS_SEND")
           (maintain-proposal {@self submit_application ?app})))

; === the verdict (read, held, in the morning post) ==================================
; An OFFER: take up the post (a sub-task carrying the same job + articles as apply_for).
(npc-think af_take_up
  (task {@self apply_for ?jk ?art})
  (role ?ltr [k offer_letter] {@self read ?ltr /ever})
  (utility 77)
  (effects (debug-print "JS_TAKEUP")
           (maintain-proposal {@self take_up_post ?jk ?art})))

; A REJECTION: conclude the apply_for /fail - the /fail conclusion IS the re-application
; memory (the pick excludes this job+org forever after).
(npc-think af_rejected
  (task {@self apply_for ?jk ?art}:?af)
  (role ?ltr [k rejection_letter] {@self read ?ltr /ever})
  (effects (set-outcome ?af fail)))

; === take_up_post sub-task: go to the workplace and take the post ===================
(npc-think tup_go
  (task {@self take_up_post ?jk ?art})
  (when (and (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (not (in-building ?wp))))
  (utility 78)
  (effects (maintain-proposal {@self enter ?wp})))

; at the workplace: enrol himself on the wage book (the hire is realized by taking it up).
; ?jk rides straight off the take_up_post task gate.
(npc-think tup_take
  (task {@self take_up_post ?jk ?art})
  (when (and (read-doc-record [k articles_of_incorporation] ?art (building ?wp))
             (in-building ?wp)
             (>= (now-hour) 9)
             (<= (now-hour) 16)
             (none {@self job.salary ?})))
  (utility 79)
  (effects (maintain-proposal {@self take_post ?art ?jk})))

; POST-ACT: read his own wage-book row (level) -> the full job object (hire-beliefs).
(npc-think tup_read_book
  (task {@self take_up_post ?jk ?art})
  (role ?reg [k employee_register] (select (policy first-match)))
  (when (and (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
             (read-doc-record [k employee_register] ?reg (find worker @self) (level ?lvl))))
  (effects (hire-beliefs ?art ?jk ?lvl)))

; === take_up_post OUTCOME: enrolled -> succ. Each task concludes ONLY itself (the
; conventions' twin-outcome rule), and the chain concludes BOTTOM-UP: the child
; stamps off the world signal (job.salary), and the child's /succ IS the parent's
; conclusive signal below - no race with the parent's gate-fall withdrawal.
(npc-think tup_succeeded
  (task {@self take_up_post ?jk ?art}:?tup)
  (role @self {@self job.salary ?})
  (effects (debug-print "TUP_SUCC art=?art")
           (set-outcome ?tup succ)))

; === apply_for OUTCOME: the take-up concluded /succ -> employed -> succ =============
(npc-think af_succeeded
  (task {@self apply_for ?jk ?art}:?af)
  (role @self (believes {@self take_up_post ?jk ?art /succ}))
  (effects (set-outcome ?af succ)))

; === the morning post: pick up + read (held) each unread letter at home =============
; The home is bound MENTAL ({@self home ?home}) - a think must stay mental-only, so the
; abs `home-of` op cannot be used here; ?home externalizes only inside the effect ops.
(npc-think read_post
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (when (in-building ?home))
  (effects
    (for-each ?ltr (attr-values (mail-pile (mail-space ?home)) items [k letter])
      (if (none {@self read ?ltr})
          (then (take-from-stack ?ltr)
                (read-document ?ltr)
                (file-in-stack ?ltr (mail-space ?home)))))))
