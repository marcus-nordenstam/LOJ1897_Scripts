; ----------------------------------------------------------------------------
; send_mail ?doc - post a composed document from HOME (a sub-task of whatever errand
; wrote it: applying for a job, courting). The knowledge-honest send lane, the mirror
; of read_mail: if @self does not know where the home's outgoing_mail_stack is,
; LOCATE it (which wanders home, learning its rooms and perceiving the pile); once
; known, go stand in its room and deposit ?doc (the post_mail act). The magic mail
; service then teleports the posted doc to the addressee building each morning.
;
; Posting carries the composing errand's priority - otherwise a jobless applicant
; keeps going BACK to apply for more jobs (higher utility) and never posts the paper
; he already wrote. The rungs step UP (home < locate < go < deposit) so a started
; posting finishes.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think send_mail_home
  (task {@self send_mail ?doc})
  (role ?home {@self home ?home})
  (when (not (in-building @self ?home)))
  (effects (debug-print "SM_HOME") (maintain-proposal {@self enter ?home})))

; find the home's outgoing pile once - locate wanders home, and concludes at once if
; its whereabouts are already known (the durable location belief).
(npc-think send_mail_locate
  (lock-rule)
  (task {@self send_mail ?doc})
  (role ?home {@self home ?home})
  ; /succ, not /ever - the same interrupted-attempt trap as read_mail_locate.
  (when (and (in-building @self ?home)
             (none {@self locate [k outgoing_mail_stack] ?home /succ})))
  (utility errand)
  (effects (debug-print "SM_LOC") (begin-proposal {@self locate [k outgoing_mail_stack] ?home})))

(npc-think send_mail_go
  (task {@self send_mail ?doc})
  (role ?home {@self home ?home})
  (role ?out [k outgoing_mail_stack] (not (co-present ?out @self)))
  (when (and (in-building ?out ?home)
             (location ?out): ?room))
  (effects (debug-print "SM_GO") (maintain-proposal {@self WALK ?room})))

; standing at the pile -> deposit. The (none .. post_mail /succ) guard drops the rung
; the instant the paper is filed, so the maintain never re-proposes onto an
; already-posted letter.
(npc-think send_mail_put
  (task {@self send_mail ?doc})
  (role ?out [k outgoing_mail_stack] (co-present ?out @self))
  (when (none {@self POST_MAIL ?doc ? /succ}))
  (effects (debug-print "SM_PUT") (maintain-proposal {@self POST_MAIL ?doc ?out})))

(npc-think send_mail_done
  (task {@self send_mail ?doc}:?sm)
  (when (any {@self POST_MAIL ?doc ? /succ} (out int)))
  (effects (debug-print "SM_DONE") (set-outcome ?sm succ)))
