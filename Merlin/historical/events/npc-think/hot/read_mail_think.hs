; ----------------------------------------------------------------------------
; read_mail ?prem - fetch and read @self's mail at ?prem's mailbox. The knowledge-
; honest receive lane, composed from the general tasks: if @self does not know where
; ?prem's incoming mail_stack is, LOCATE it (which wanders ?prem, learning its rooms
; and perceiving the stack); once known, go stand in its room, lift the letters
; addressed to @self (or to a duty @self holds) via take_my_letters, and read each
; held one. Concluded once the stack has been swept this round and @self's hands are
; empty. Drives homebody, applicant and recruiter receipt alike - the driver just
; names the premises (home for residents, the workplace for the recruit officer).
;
; The stack is bound SCOPED to ?prem via the location.building chain, so a recruiter
; who knows his home mailbox never confuses it with the workplace inbox.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; DRIVER - the daily home post: at home, read the home mail once a day. DISABLED: it
; has never fired (its old (building-co-present @self) filter sourced PEOPLE in @self's
; building, but ?home is a BUILDING, so the {@self home ?home} residual never matched).
; The at-home form below is correct, but at utility 85 it dominates and starves mail
; POSTING - re-enable only with a utility/cadence retune. Residents' home mail therefore
; goes unread for now; the recruit officer's workplace read_mail rides the recruit_staff
; duty independently.
; (npc-think want_read_mail
;   (role ?home {@self home ?home} {@self location.building ?home})
;   (when (>= (days-since-last {@self read_mail ?home /succ}) 1))
;   (utility 85)
;   (effects (debug-print "WANT_RM") (maintain-proposal {@self read_mail ?home})))

; (1) find ?prem's mailbox once - locate wanders ?prem, and concludes at once if its
; whereabouts are already known (the durable location belief). One locate per premises.
(npc-think read_mail_locate
  (task {@self read_mail ?prem})
  ; /succ, not /ever: an INTERRUPTED locate must retry - an /ever guard lets a
  ; night-owl's one starved attempt close the gate forever and the round stalls
  ; bodiless at go (the stack is never learned).
  (when (none {@self locate [k mail_stack] ?prem /succ}))
  (utility errand)
  (effects (debug-print "RM_LOC") (begin-proposal {@self locate [k mail_stack] ?prem})))

; (2) known -> go stand in the room the stack is in.
(npc-think read_mail_go
  (task {@self read_mail ?prem})
  (role ?stk [k mail_stack] (in-building ?stk ?prem)
                            (not (co-present ?stk @self)))
  (when (location ?stk): ?room)
  (effects (maintain-proposal {@self WALK ?room})))

; (3) co-located, not yet swept this read -> sort the pile (take_my_letters
; rides the generic stack_browse; the looking lives there).
(npc-think read_mail_take
  (task {@self read_mail ?prem}:?rm)
  (role ?stk [k mail_stack] (in-building ?stk ?prem)
                            (co-present ?stk @self))
  (when (none {@self take_my_letters ?stk /caused_by ?rm /ever}))
  (utility errand)
  (effects (debug-print "RM_TAKE")
           (begin-proposal {@self take_my_letters ?stk})))

; (4) holding a letter -> read it (the read act ingests the writing and sets it down).
(npc-think read_mail_read
  (task {@self read_mail ?prem})
  (role ?ltr [k letter] (spatial @self hold))
  (effects (maintain-proposal {@self READ ?ltr})))

; Swept this read AND nothing left to READ -> concluded. LETTERS only, by design:
; the read act is this task's release (it sets each read letter down), while the
; duty scan's applications stay in hand PAST this conclusion - they are the recruit
; lane's work items, released by resolve_applications, not reading material.
(npc-think read_mail_done
  (task {@self read_mail ?prem}:?rm)
  (role ?stk [k mail_stack] (in-building ?stk ?prem))
  (when (and (believes {@self take_my_letters ?stk /succ /caused_by ?rm})
             (empty (spatial @self hold [k letter]))))
  (effects (debug-print "RM_DONE") (set-outcome ?rm succ)))

; NO give-up rung: an interrupted round keeps its resumable node and RESUMES on
; the next premises visit - away from ?prem the rungs simply propose nothing
; (their in-building/co-present gates fail) and the task idles running. The old
; conclusive /fail existed to break a re-promotion livelock that the engine
; fixes (fire-time producer-pool re-verify + the /caused_by matcher routing)
; have since killed at the root; concluding here threw away the round's
; progress on every excursion and a night-owl seeker never finished a sweep.

(npc-think read_mail_tmp_probe
  (task {@self read_mail ?prem})
  (effects (debug-print "RM_P_TASK prem=?prem")))

(npc-think rm_sat_probe
  (role ?home {@self home ?home})
  (when (and (in-building @self ?home) (>= (now-hour) 6) (<= (now-hour) 11)))
  (effects
    (tolerate (now-abs-seconds): ?n)
    (tolerate (abs-seconds (highest /end {@self read_mail ?home /succ}).end): ?e)
    (debug-print "RM_SAT n=?n e=?e")))
