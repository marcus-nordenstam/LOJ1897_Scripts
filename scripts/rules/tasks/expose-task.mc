; ----------------------------------------------------------------------------
; expose ?victim - denounce the victim's non-spousal liaison publicly. @self tells the
; victim the secret to his face (the room hears {?victim lover ?partner} through the real
; auditory channel), then publish-secret-about seeds
; the victim's circle and the scandal spreads town-wide. A published secret is spent
; leverage, so any standing {@self extort ?victim} anchor ends. The ended {@self expose
; ?victim} belief IS the deed memory; the crime row records it. Nothing to expose
; (no known liaison) or a dead victim -> abandon.
;
; DEFERRED: the anonymous_letter sibling method (a covert posted denunciation) - the
; confront (spoken) method is the migration; the letter method + the quoted barb content
; land later. publish-secret-about is a legitimate gossip cascade, not a fiat write.
; ----------------------------------------------------------------------------

(task {@self expose ?victim}:?expose
  (tar @pattern)
  (construed-act expose-act betray-act wrong-act) (contradicts privacy)
  (and
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and -{@self spouse ?victim}
                   {?victim lover|HAVE-SEX-WITH ?partner /ever}
                   -{?victim spouse ?partner /ever}
                   -{@self spouse ?partner}
                   (not (spatial ?victim co-located @self))
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go-to ?vhome}))))
    (try
      (when (and -{@self spouse ?victim}
                 {?victim lover|HAVE-SEX-WITH ?partner /ever}
                 -{?victim spouse ?partner /ever}
                 -{@self spouse ?partner}
                 (or (spatial ?victim co-located @self) (spatial ?victim space))
                 -{@self tell ? ?victim /succ /caused_by ?expose}))
      (declare-utility errand always-pick)
      (effects (maintain-proposal {@self tell (utterable-msg [] {?victim lover ?partner}) ?victim})))
    (try
      (when {@self tell ? ?victim /succ /caused_by ?expose})
      (effects
        ; TELEPATHY - this pushed the secret into every other mind. The SAY above is
        ; already the honest channel; the spread belongs to the hearers' own adoption.
        ; Commented out pending that redesign.
        ; (publish-secret-about @self ?victim)
        (if {@self extort ?victim} (then (end-belief {@self extort ?victim})))
        (record-crime @self ?victim confront-publicly expose @u @u)
        (set-outcome ?expose /succ)))
    (try
      (when (or (not (and -{@self spouse ?victim}
                          {?victim lover|HAVE-SEX-WITH ?partner /ever}
                          -{?victim spouse ?partner /ever}
                          -{@self spouse ?partner}))
                (not (alive ?victim))))
      (effects (set-outcome ?expose /fail)))))
