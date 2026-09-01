; ----------------------------------------------------------------------------
; send-mail ?doc - post a composed document from HOME (the mirror of read-mail). If @self
; does not know where the home's outgoing-mail-stack is, LOCATE it (wandering home); once
; known, go to its room and deposit ?doc (the post_mail act). The magic mail service then
; teleports the posted doc to the addressee building each morning. The tries step UP (home
; < locate < go < deposit) so a started posting finishes; posting carries the composing
; errand's priority.
; ----------------------------------------------------------------------------

(npc-task {@self send-mail ?doc}:?sm-rel
  (tar document)
  (and
    (try
      (role ?home {@self home ?home})
      (when (not (spatial @self building ?home)))
      (effects (debug-print "SM_HOME") (maintain-proposal {@self enter ?home})))
    (try
      (lock-rule)
      (role ?home {@self home ?home})
      (when (and (spatial @self building ?home)
                 -{@self locate [k outgoing-mail-stack] ?home /succ}))
      (utility errand)
      (effects (debug-print "SM_LOC")
               (begin-proposal {@self locate [k outgoing-mail-stack] ?home})))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (not (spatial ?out co-located @self)))
      (when (and (spatial ?out building ?home)
                 (spatial ?out space): ?room))
      (effects (debug-print "SM_GO") (maintain-proposal {@self WALK ?room})))
    (try
      (role ?out [k outgoing-mail-stack] (spatial ?out co-located @self))
      (when -{@self STACK-PUT ?doc ? /succ})
      (effects (debug-print "SM_PUT") (maintain-proposal {@self STACK-PUT ?doc ?out})))
    (try
      (when {@self STACK-PUT ?doc ? /succ})
      (effects (debug-print "SM_DONE") (set-outcome ?sm-rel /succ)))))
