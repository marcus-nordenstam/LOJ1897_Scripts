; ----------------------------------------------------------------------------
; job_search - the WORKER side of the labour market (the recruiter side lives in
; recruit_think.hs; the shared clerical acts in recruit_actions.hs).
;
; The whole hunt rides ONE reified object: the `application` DOCUMENT. The seeker
; writes it, leaves it at the workplace, and its single `status` state carries the
; lifecycle end to end:
;
;   applied    the seeker submitted it (the physical paper on the recruiter's desk)
;   offered    the recruiter's reply letter said yes  -> take up the post
;   rejected   the recruiter's reply letter said no   -> tear it up, hunt on
;   accepted   the seeker returned and signed          -> enrolment follows
;
;   GOAL {@self seek_work}   the standing hunt want_work mints while jobless.
;   TASK apply ?ad           pursue one advert: go to its workplace, leave an
;                            application there.
;   TASK take_up_post ?app   the offer arrived: return, sign the application,
;                            read the wage book - employment is REALIZED by
;                            reading one's own row (hire-beliefs), never injected.
;
; "Employed" is not a state: it is simply holding a {@self job ?} that carries a
; salary. Every cross-NPC hop is a physical document or a letter - no mind reads.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- the decision: a jobless working-age adult wants work ----------------------
(npc-think want_work
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (not (believes {@self job.salary ?})))
  ; The staggered take-up: a third of the jobless start hunting in any given
  ; round instead of every jobless adult stampeding the board the same day.
  ; latch-eval locks a PASSED roll for the bout.
  (when (and (>= (years-old @self) 16)
             (<= (years-old @self) 55)
             (not (= (situation @self repute) [k scandalous]))
             (latch-eval (chance 0.3))))
  (effects       (debug-print "TRACE-WANTWORK begin-seek")
                 (begin-goal {@self seek_work}))
  ; The minter owns the end: once a salaried job is held the jobless role drops
  ; and this falling edge ends the hunt.
  (cease-effects (end-goal {@self seek_work})))

; --- rung: visit the parish board (monthly while hunting) ----------------------
(npc-think seek_board_visit
  (cooldown 1 m)
  (goal {@self seek_work})
  (when (and (bind (find-building [k building church]) ?board)
             (not (in-building ?board))))
  (utility 71)
  (effects (debug-print "TRACE-BOARDVISIT board=?board")
           (maintain-proposal {@self enter ?board})))

; --- decision: at the board, answer an eligible advert I can fill --------------
; ONE application in flight at a time ((not (believes {@self submit ?}))): the
; seeker commits to a post and waits for its verdict before answering another.
; The advert doc carries its own workplace / floor / job - re-read on demand, so
; the seeker keeps no advert-specific beliefs.
; The advert is rolled at random (roulette over the board) so an ineligible or
; already-rejected post is simply not picked THIS cycle and another is tried next -
; no deterministic lock onto one unfillable posting. One pursuit at a time (no
; live apply task, no application in flight).
(npc-think apply_pick
  (rng-stream employment)
  (goal {@self seek_work})
  (role ?ad [k job_description] (select (score 1) (policy roulette)))
  (when (and (co-present @self ?ad)
             (not (believes {@self apply ?}))
             (not (believes {@self submit ?}))
             (read-doc-record [k job_description] ?ad (class_floor ?cf))
             (class-at-least @self ?cf)))
  (utility 73)
  (effects (debug-print "TRACE-APPLYPICK ad=?ad")
           (maintain-proposal {@self apply ?ad})))

; --- the application task: go to the workplace named on the advert -------------
(npc-think apply_go
  (role @self (believes {@self apply ?ad}))
  (when (and (read-doc-record [k job_description] ?ad (workplace ?wp))
             (not (in-building ?wp))))
  (utility 74)
  (effects (debug-print "TRACE-APPLYGO ad=?ad wp=?wp")
           (maintain-proposal {@self enter ?wp})))

; At the workplace in business hours: write the application and leave it there.
(npc-think apply_submit
  (role @self (believes {@self apply ?ad}))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 16)
             (read-doc-record [k job_description] ?ad (workplace ?wp))
             (in-building ?wp)))
  (utility 75)
  (effects (debug-print "TRACE-APPLYSUBMIT ad=?ad wp=?wp")
           (maintain-proposal {@self submit_application ?ad})))

; --- the verdict arrives by letter (read at home, morning post) ----------------
; A rejection: tear up the paper and free the seeker to answer another advert.
(npc-think reject_reset
  (role @self (believes {@self submit ?app}))
  (when (believes {?app status [k rejected]}))
  (effects
    (debug-print "TRACE-REJECTED app=?app")
    (end-belief {@self submit ?app})))

; An offer: take up the post.
(npc-think offer_pickup
  (role @self (believes {@self submit ?app}))
  (when (believes {?app status [k offered]}))
  (utility 76)
  (effects (debug-print "TRACE-OFFERPICKUP app=?app")
           (maintain-proposal {@self take_up_post ?app})))

; --- the take-up task: return, sign, read the wage book ------------------------
(npc-think tup_go
  (role @self (believes {@self take_up_post ?app}))
  (when (and (read-doc-record [k application] ?app (workplace ?wp))
             (not (in-building ?wp))))
  (utility 77)
  (effects (maintain-proposal {@self enter ?wp})))

; At the workplace, sign the offered application (status -> accepted).
(npc-think tup_accept
  (role @self (believes {@self take_up_post ?app}))
  (when (and (>= (now-hour) 9)
             (<= (now-hour) 16)
             (read-doc-record [k application] ?app (find status [k offered]) (workplace ?wp))
             (in-building ?wp)))
  (utility 78)
  (effects (maintain-proposal {@self accept_post ?app})))

; Signed: read the wage book (the recruiter enrols on the accepted paper; the row
; appears; reading it realizes employment).
(npc-think tup_read_book
  (role @self (believes {@self take_up_post ?app}))
  (role ?reg [k employee_register] (select (policy first-match)))
  (when (and (read-doc-record [k application] ?app (find status [k accepted]))
             (co-present @self ?reg)))
  (utility 79)
  (effects (maintain-proposal {@self read ?reg})))

; POST-ACT: my own wage-book row read back -> the full job object (org / salary /
; level / since / shifts) via the shared hire-beliefs macro. job.salary now holds
; -> want_work's falling edge ends the hunt.
(npc-think employment_realized
  (role @self (believes {@self take_up_post ?app}))
  (role ?reg [k employee_register] (select (policy first-match)))
  (when (and (believes {@self read ?reg /succ})
             (read-doc-record [k employee_register] ?reg (find worker @self) (job ?jk) (level ?lvl))
             (read-doc-record [k application] ?app (org_record ?art))))
  (effects
    (debug-print "TRACE-HIRED app=?app jk=?jk")
    (hire-beliefs ?art ?jk ?lvl)
    (end-belief {@self submit ?app})
    (end-belief {@self take_up_post ?app})))

; --- the morning post: read unread letters at home -----------------------------
(npc-think read_letters
  (role ?letter [k letter]
                (not (believes {@self read ?letter}))
                (select (policy first-match)))
  (when (co-present @self ?letter))
  (utility 72)
  (effects (maintain-proposal {@self read ?letter})))
