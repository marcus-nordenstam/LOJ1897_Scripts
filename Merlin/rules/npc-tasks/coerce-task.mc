; ----------------------------------------------------------------------------
; coerce ?victim - press a threat on the victim to standing effect. @self reaches the
; victim and SAYs the threat aloud (the real auditory channel - the co-present victim
; ADOPTS {<speaker> extort @self}, the coercion anchor his own coercion_pressure reads;
; anyone else in earshot hears it too). NO fiat cross-mind write. @self also holds the
; ACTOR-side {@self extort ?victim} anchor in his OWN mind, which coercion_think then
; re-presses monthly. The deed is ledgered by method - blackmail when @self holds
; leverage, else threaten_violence. The ended {@self coerce ?victim} belief IS the deed
; memory. No live victim -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self coerce ?victim}:?coerce-rel
  (track-skill-level [k illicit])
  (tar human)
  (aux ?)
  (construed-act coercion-act wrong-act)
  (facets reportable_crime)
  (and
    (try
      (when (and (not (spatial ?victim co-located @self))
                 (spatial ?victim space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (role ?vhome {?victim home ?vhome})
      (when (and (not (spatial ?victim co-located @self))
                 (unknown (spatial ?victim space))))
      (effects (maintain-proposal {@self go ?vhome})))
    (try
      (when (and (spatial ?victim co-located @self)
                 -{@self extort ?victim}))
      (utility errand always-pick)
      (effects (maintain-proposal
                 {@self SAY (utterable-msg {@self extort ?victim}) ?victim})))
    (try
      (when {@self SAY ? ?victim /succ /caused_by ?coerce-rel})
      (effects
        (if -{@self extort ?victim} (then (begin-belief {@self extort ?victim})))
        (if (holds-coercion-material ?victim)
            (then (crime-ledger-append @self ?victim blackmail coerce @u @u))
            (else (crime-ledger-append @self ?victim threaten_violence coerce @u @u)))
        (set-outcome ?coerce-rel /succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?coerce-rel /fail)))))
