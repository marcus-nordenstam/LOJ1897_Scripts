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
    ; go, NEVER the raw WALK: reaching a place is go's whole job and it dispatches to enter or
    ; WALK by what the destination is. WALK alone cannot let him into a building he is not
    ; already in, so a man posting from across town never arrived and STACK-PUT's reach check
    ; aborted the run.
    (stage
      (effects
        (if (not (spatial ?out co-located @self))
            (then (maintain-proposal {@self go (spatial ?out space)})))))

    ; The put is proposed only AT the pile: the walk is the stage before, but a man can be
    ; pulled away between stages, and STACK-PUT asserts the reach it is given. The stage
    ; HOLDS until he is back at it.
    (stage
      (role @self (spatial ?out co-located @self))
      (effects (maintain-proposal {@self STACK-PUT ?doc ?out})))

    (stage
      (effects (set-outcome ?sm-rel /succ)))))
