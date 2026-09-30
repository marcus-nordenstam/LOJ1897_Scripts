; ----------------------------------------------------------------------------
; magic-mail-service - the town's post, run by the engine at every midnight
; (define-func /nightly: mindless, abs plane, no @self). Every letter a sender
; has deposited in an outgoing-mail-stack teleports to the incoming mail-stack of the
; household whose address is written on it - a unit of a building, or a building that has
; none. A letter with no address, or one no mail-stack answers, is a dead letter and stays
; in the outgoing pile.
; ----------------------------------------------------------------------------

(define-func /nightly magic-mail-service ()
  (for-each ?out (env-entities [k outgoing-mail-stack])
    (for-each ?ltr (spatial ?out items /env)
      (attr ?ltr destination): ?dest
      (if (substantial ?dest)
        (then
          ; A letter is delivered to the HOUSEHOLD: an address naming a room in it still names
          ; it, so the match is below the unit rung, against the room the pile stands in.
          (address-household ?dest): ?to
          (for-each ?in (env-entities [k mail-stack])
            (if (= (address-household (attr (spatial ?in space /env) address)) ?to)
              (then
                (push ?ltr ?in)
                (break)))))))))
