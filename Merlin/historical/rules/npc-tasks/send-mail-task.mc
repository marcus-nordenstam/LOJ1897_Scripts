; ----------------------------------------------------------------------------
; send-mail ?doc - post a composed document from HOME (the mirror of read-mail). If @self
; does not know where the home's outgoing-mail-stack is, LOCATE it (wandering home); once
; known, go to its room and deposit ?doc (the post_mail act). The magic mail service then
; teleports the posted doc to the addressee building each morning. The tries step UP (home
; < locate < go < deposit) so a started posting finishes; posting carries the composing
; errand's priority.
;
; NO (when ..) anywhere: every conjunct here is a constraint on a BINDING - which home,
; which stack, whether @self has already posted this doc - so every one belongs on the role
; it constrains. In the gate they would be re-read live on every deliberation cycle and be
; invisible to the wake machinery; on the role they are cached, and a write under the label
; re-tests membership and arms the rule. WHICH stack in particular is role work: every
; building in the parish carries an outgoing-mail-stack, so an unconstrained ?out ranges
; over every one @self has ever stood beside.
; ----------------------------------------------------------------------------

(npc-task {@self send-mail ?doc}:?sm-rel
  (tar document)
  (and
    (try
      (role ?home {@self home ?home}
                  (not (spatial @self building ?home)))
      (effects (maintain-proposal {@self enter ?home})))
    (try
      (lock-rule)
      (role ?home {@self home ?home}
                  (spatial @self building ?home)
                  -{@self locate [k outgoing-mail-stack] ?home /succ})
      (utility errand)
      (effects
               (begin-proposal {@self locate [k outgoing-mail-stack] ?home})))
    (try
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (spatial ?out building ?home)
                                         (not (spatial ?out co-located @self))
                                         (spatial ?out space): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    (try
      (role @self -{@self STACK-PUT ?doc ? /succ})
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (spatial ?out building ?home)
                                         (spatial ?out co-located @self))
      (effects (maintain-proposal {@self STACK-PUT ?doc ?out})))
    (try
      (role @self {@self STACK-PUT ?doc ? /succ})
      (effects (set-outcome ?sm-rel /succ)))))
