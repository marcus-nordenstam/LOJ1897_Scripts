; ----------------------------------------------------------------------------
; confess-letter ?focus - reveal @self's OWN non-spousal liaison to the nearest living
; kin by letter: scandal without murder, and the leak kills any standing blackmail
; leverage once the secret is out. NOT a crime - no ledger. The kin is the first close
; relation on the father > mother > fiancee > spouse > sibling ladder (one option
; read); the confessed partner must be a real third party. Handing the confession-letter
; to the mail lane IS the deed - the magic mail service delivers it and the kin learns the
; lover fact at their next home read - so the compose try concludes the task whether or not
; a living, non-partner, locatable kin was there to receive it (the impulse is spent either
; way, mirroring the old terminal). Nothing confessable / no kin at all -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self confess-letter ?focus}:?confess-rel
  (tar human)
  (construed-act honour-act)
  (and
    (try
      (role @self -{@self send-mail ? ? /succ /caused_by ?confess-rel})
      (role ?my-home {@self home ?my-home})
      (role ?my-out-box [k outgoing-mail-stack] (spatial ?my-out-box building ?my-home))
      (when (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                 -{@self spouse ?partner /ever}
                 {@self father|mother|fiancee|spouse|sibling ?kin}))
      (utility errand)
      (effects
        (if (and (alive ?kin) (!= ?kin ?partner) {?kin home ?kinhome})
            (then (post-letter [k confession-letter]
                               (nl-written-msg "I have taken ?partner as a lover")
                               ?kinhome ?kin ?my-out-box))
            (else (set-outcome ?confess-rel /fail)))))
    ; The letter is in the post: the confession is made.
    (try
      (when {@self send-mail ? ? /succ /caused_by ?confess-rel})
      (effects (set-outcome ?confess-rel /succ)))
    (try
      (when (or (not (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                          -{@self spouse ?partner /ever}))
                -{@self father|mother|fiancee|spouse|sibling ?}))
      (effects (set-outcome ?confess-rel /fail)))))
