; ----------------------------------------------------------------------------
; close-to (classifier) - the confidant tie: a friend @self has come to adore, or to rely on.
; It forms when the friendship and either feeling hold, and it goes when neither feeling is
; left or the friendship ends. The tie is what makes a friend close (states.mon closeness), so
; a confidant hears what only close friends are told.
; ----------------------------------------------------------------------------

(think classify-close-to
  ; Monthly: warmth and trust drift, so a friend grows into (or out of) a confidant between
  ; the bond changes that would otherwise re-test this.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (and
    (try
      (role ?other {@self friend ?other} {@self adore|rely ?other} -{@self close-to ?other}
        (effects (begin-belief {@self close-to ?other}))))
    (try
      (role ?other {@self close-to ?other}
                   (or -{@self friend ?other} (none {@self adore|rely ?other}))
        (effects (end-belief {@self close-to ?other}))))))
