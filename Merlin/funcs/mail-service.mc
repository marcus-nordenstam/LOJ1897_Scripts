; ----------------------------------------------------------------------------
; magic-mail-service - the town's post, run by the engine ONCE at the end of every sim
; window (define-func /window-end: mindless, abs plane, no @self). Every letter a sender
; has deposited in a building's outgoing-mail-stack teleports to the incoming mail-stack
; of the building whose address is written on it. A letter with no address, or one no
; building carries at its premises rung, is a dead letter and stays in the outgoing pile.
; ----------------------------------------------------------------------------

(define-func /window-end magic-mail-service ()
  (for-each ?out (env-entities [k outgoing-mail-stack])
    (for-each ?ltr (spatial ?out items /env)
      (attr ?ltr destination): ?dest
      (if (substantial ?dest)
        (then
          (for-each ?b (env-entities [k building])
            ; A letter is delivered to the HOUSE: an address naming a room in it still names
            ; it, so the match is at the premises rung.
            (if (= (attr ?b address) (address-premises ?dest))
              (then
                (for-each ?in (env-entities [k mail-stack])
                  (if (spatial ?in building ?b /env)
                    (then
                      (push ?ltr ?in)
                      (break))))
                (break)))))))))
