; ----------------------------------------------------------------------------
; magic-mail-service - the town's post, run by the engine ONCE at the end of every sim
; window (define-func /window-end: mindless, abs plane, no @self). Every letter a sender
; has deposited in a building's outgoing-mail-stack teleports to the incoming mail-stack
; of the building whose address is written on it. A letter with no address, or one no
; building carries, is a dead letter and stays in the outgoing pile.
; ----------------------------------------------------------------------------

(define-func /window-end magic-mail-service ()
  (for-each ?out (env-entities [k outgoing-mail-stack])
    (for-each ?ltr (spatial ?out items /env)
      (attr ?ltr destination): ?dest
      (if (substantial ?dest)
        (then
          (for-each ?b (env-entities [k building])
            (if (= (attr ?b address) ?dest)
              (then
                (for-each ?in (env-entities [k mail-stack])
                  (if (spatial ?in building ?b /env)
                    (then
                      (push ?ltr ?in)
                      (break))))
                (break)))))))))
