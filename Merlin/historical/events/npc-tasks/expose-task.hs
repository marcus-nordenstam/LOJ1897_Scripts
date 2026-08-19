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
  (construed_act expose_act betray_act wrong_act)
  (and
    (try
      (when (and (known-nonspousal-liaison ?victim)
                 (not (spatial ?victim co-located @self))
                 (spatial ?victim space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (known-nonspousal-liaison ?victim)
                 (not (spatial ?victim co-located @self))
                 (unknown (spatial ?victim space))))
      (effects (maintain-proposal {@self go (home-of ?victim)})))
    (try
      (when (and (known-nonspousal-liaison ?victim): ?partner
                 (spatial ?victim co-located @self)
                 (none {@self SAY ? /succ /caused_by ?expose-rel})))
      (utility errand always-pick)
      (effects (maintain-proposal {@self SAY (utterable-msg {?victim lover ?partner}) _})))
    (try
      (when (any {@self SAY ? /succ /caused_by ?expose-rel}))
      (effects
        (publish-secret-about @self ?victim)
        (if (any {@self extort ?victim} (out int)) (then (end-belief {@self extort ?victim})))
        (crime-ledger-append @self ?victim confront_publicly expose @u @u)
        (set-outcome ?expose-rel succ)))
    (try
      (when (or (not (known-nonspousal-liaison ?victim))
                (not (alive ?victim))))
      (effects (set-outcome ?expose-rel fail)))))
