; ----------------------------------------------------------------------------
; send-mail ?doc ?out - post a composed document into ?out, an outgoing-mail-stack the
; proposing task CHOSE and knows: an applicant's home out-box, a recruiting officer's office
; out-box. The task presumes no mailbox and searches for none: if @self does not know an
; out-box, the caller locates one first. Go to the stack's room, deposit ?doc (STACK-PUT);
; the magic mail service then carries the posted doc to the address written on it.
; ----------------------------------------------------------------------------

(npc-task {@self send-mail ?doc ?out}:?sm-rel
  (tar document)
  (aux stack)
  (and
    (try
      (role @self (not (spatial ?out co-located @self))
                  (spatial ?out space): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    (try
      (role @self (spatial ?out co-located @self)
                  -{@self STACK-PUT ?doc ?out /succ})
      (effects (maintain-proposal {@self STACK-PUT ?doc ?out})))
    (try
      (role @self {@self STACK-PUT ?doc ?out /succ})
      (effects (set-outcome ?sm-rel /succ)))))
