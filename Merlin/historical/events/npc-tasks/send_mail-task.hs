; ----------------------------------------------------------------------------
; send_mail ?doc - post a composed document from HOME (the mirror of read_mail). If @self
; does not know where the home's outgoing_mail_stack is, LOCATE it (wandering home); once
; known, go to its room and deposit ?doc (the post_mail act). The magic mail service then
; teleports the posted doc to the addressee building each morning. The tries step UP (home
; < locate < go < deposit) so a started posting finishes; posting carries the composing
; errand's priority.
; ----------------------------------------------------------------------------

(npc-task {@self send_mail ?doc}:?sm
  (tar document)
  (and
    (try
      (role ?home {@self home ?home})
      (when (not (in-building @self ?home)))
      (effects (debug-print "SM_HOME") (maintain-proposal {@self enter ?home})))
    (try
      (lock-rule)
      (role ?home {@self home ?home})
      (when (and (in-building @self ?home)
                 (none {@self locate [k outgoing_mail_stack] ?home /succ})))
      (utility errand)
      (effects (debug-print "SM_LOC")
               (begin-proposal {@self locate [k outgoing_mail_stack] ?home})))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing_mail_stack] (not (co-present ?out @self)))
      (when (and (in-building ?out ?home)
                 (location ?out): ?room))
      (effects (debug-print "SM_GO") (maintain-proposal {@self WALK ?room})))
    (try
      (role ?out [k outgoing_mail_stack] (co-present ?out @self))
      (when (none {@self POST_MAIL ?doc ? /succ}))
      (effects (debug-print "SM_PUT") (maintain-proposal {@self POST_MAIL ?doc ?out})))
    (try
      (when (any {@self POST_MAIL ?doc ? /succ} (out int)))
      (effects (debug-print "SM_DONE") (set-outcome ?sm succ)))))
