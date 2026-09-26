; ----------------------------------------------------------------------------
; close-to (classifier) - the confidant tie: a friend @self has come to adore, or to rely on.
; It forms when the friendship and either feeling hold, and it goes when neither feeling is
; left or the friendship ends. The tie is what makes a friend close (states.mon closeness), so
; a confidant hears what only close friends are told.
; ----------------------------------------------------------------------------

(npc-think classify_close_to
  ; Monthly: warmth and trust drift, so a friend grows into (or out of) a confidant between
  ; the bond changes that would otherwise re-test this.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role ?other (or {@self friend ?other} {@self close-to ?other})

    (effects
      (if (and {@self friend ?other} (or {@self adore ?other} {@self rely ?other}))
          (then (if -{@self close-to ?other} (then (begin-belief {@self close-to ?other}))))
          (else (end-belief {@self close-to ?other}))))))
