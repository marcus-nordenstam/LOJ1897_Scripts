; ----------------------------------------------------------------------------
; expose ?victim - denounce the victim's non-spousal liaison publicly. @self reaches
; the victim and SAYs the secret aloud as an open BROADCAST (the room hears {?victim
; lover ?partner} through the real auditory channel), then publish-secret-about seeds
; the victim's circle and the scandal spreads town-wide. A published secret is spent
; leverage, so any standing {@self extort ?victim} anchor ends. The ended {@self expose
; ?victim} belief IS the deed memory; the crime-ledger row records it. Nothing to expose
; (no known liaison) or a dead victim -> abandon.
;
; DEFERRED: the anonymous_letter sibling method (a covert posted denunciation) - the
; confront (spoken) method is the migration; the letter method + the quoted barb content
; land later. publish-secret-about is a legitimate gossip cascade, not a fiat write.
; ----------------------------------------------------------------------------

(npc-task {@self expose ?victim}:?expose-rel
  (tar @S)
  (construed-act expose-act betray-act wrong-act) (contradicts privacy)
  (and
    (try
      (when (and -{@self spouse ?victim}
                 {?victim lover|HAVE-SEX-WITH ?partner /ever}
                 -{?victim spouse ?partner /ever}
                 -{@self spouse ?partner}
                 (not (spatial ?victim co-located @self))
                 (spatial ?victim space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and -{@self spouse ?victim}
                 {?victim lover|HAVE-SEX-WITH ?partner /ever}
                 -{?victim spouse ?partner /ever}
                 -{@self spouse ?partner}
                 (not (spatial ?victim co-located @self))
                 (unknown (spatial ?victim space))
                 {?victim home ?vhome}))
      (effects (maintain-proposal {@self go ?vhome})))
    (try
      (when (and -{@self spouse ?victim}
                 {?victim lover|HAVE-SEX-WITH ?partner /ever}
                 -{?victim spouse ?partner /ever}
                 -{@self spouse ?partner}
                 (spatial ?victim co-located @self)
                 -{@self SAY ? /succ /caused_by ?expose-rel}))
      (utility errand always-pick)
      (effects (maintain-proposal {@self SAY (utterable-msg {?victim lover ?partner}) _})))
    (try
      (when {@self SAY ? /succ /caused_by ?expose-rel})
      (effects
        ; TELEPATHY - this pushed the secret into every other mind. The SAY above is
        ; already the honest channel; the spread belongs to the hearers' own adoption.
        ; Commented out pending that redesign.
        ; (publish-secret-about @self ?victim)
        (if {@self extort ?victim} (then (end-belief {@self extort ?victim})))
        (crime-ledger-append @self ?victim confront-publicly expose @u @u)
        (set-outcome ?expose-rel /succ)))
    (try
      (when (or (not (and -{@self spouse ?victim}
                          {?victim lover|HAVE-SEX-WITH ?partner /ever}
                          -{?victim spouse ?partner /ever}
                          -{@self spouse ?partner}))
                (not (alive ?victim))))
      (effects (set-outcome ?expose-rel /fail)))))
