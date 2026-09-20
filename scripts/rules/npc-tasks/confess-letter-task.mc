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
    ; Make the paper, pen it, post it - three deeds, each reading the world for what is done.
    (try
      (role @self -{@self send-mail ? ? /succ /caused_by ?confess-rel}
        (role ?my-home {@self home ?my-home}
          (role ?ltr [k confession-letter] (spatial ?ltr co-located @self)
                                           {@self WRITE ?ltr ? /succ}
                                           -{@self send-mail ?ltr ? /succ}
            (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home)
              (utility errand)
              (effects
                (check (substantial (attr ?ltr writing)))
                (check (substantial (attr ?ltr destination)))
                (maintain-proposal {@self send-mail ?ltr ?out})))))))

    (try
      (role @self -{@self send-mail ? ? /succ /caused_by ?confess-rel}
        (role ?ltr [k confession-letter] (spatial ?ltr co-located @self)
                                         (unsubstantial (attr ?ltr writing))
          (when (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                     -{@self spouse ?partner /ever}
                     {@self father|mother|fiancee|spouse|sibling ?kin}
                     (alive ?kin)
                     (!= ?kin ?partner)
                     {?kin home ?kinhome}
                     {?kinhome address ?kin-address}
                     {?kin name ?kin-name}
                     {?partner name ?partner-name}))
          (utility errand)
          (effects
            (maintain-proposal
              {@self write-doc ?ltr
                     (written-msg [/addressee ?kin-name /address ?kin-address]
                                  {@i lover ?partner-name})})))))

    (try
      (role @self -{@self send-mail ? ? /succ /caused_by ?confess-rel}
        (when (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                   -{@self spouse ?partner /ever}
                   {@self father|mother|fiancee|spouse|sibling ?kin}
                   (alive ?kin)
                   (!= ?kin ?partner)
                   {?kin home ?}))
        (utility errand)
        (effects (maintain-proposal {@self CREATE-ENTITY [k confession-letter]}))))

    ; A kin who is dead, who IS the partner, or whose home he cannot name, receives nothing -
    ; the impulse is spent either way, exactly as the single compose try used to spend it.
    (try
      (when (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                 -{@self spouse ?partner /ever}
                 {@self father|mother|fiancee|spouse|sibling ?kin}
                 (or (not (alive ?kin))
                     (== ?kin ?partner)
                     -{?kin home ?})))
      (effects (set-outcome ?confess-rel /fail)))
    ; The letter is in the post: the confession is made.
    (try
      (when {@self send-mail ? ? /succ /caused_by ?confess-rel})
      (effects (set-outcome ?confess-rel /succ)))
    (try
      (when (or (not (and {@self lover|HAVE-SEX-WITH ?partner /ever}
                          -{@self spouse ?partner /ever}))
                -{@self father|mother|fiancee|spouse|sibling ?}))
      (effects (set-outcome ?confess-rel /fail)))))
