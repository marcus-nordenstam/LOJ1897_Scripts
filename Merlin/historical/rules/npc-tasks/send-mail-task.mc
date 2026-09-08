; ----------------------------------------------------------------------------
; send-mail ?doc ?out - post a composed document into ?out, an outgoing-mail-stack the
; proposing task CHOSE and knows: an applicant's home out-box, a recruiting officer's office
; out-box. The task presumes no mailbox and searches for none: if @self does not know an
; out-box, the caller locates one first. Walk to the stack's room if not there, deposit
; ?doc (STACK-PUT); the magic mail service then carries the posted doc to the address
; written on it.
; ----------------------------------------------------------------------------

(npc-task {@self send-mail ?doc ?out}:?sm-rel
  (tar document)
  (aux stack)
  (sequence
    (stage
      (effects
        (if (not (spatial ?out co-located @self))
            (then (maintain-proposal {@self WALK (spatial ?out space)})))))

    (stage
      (effects (maintain-proposal {@self STACK-PUT ?doc ?out})))

    (stage
      (effects (set-outcome ?sm-rel /succ)))))
