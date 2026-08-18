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

(npc-task {@self coerce ?victim}:?coerce
  (tar human)
  (aux ?)
  (construed_act coercion_act wrong_act)
  (facets reportable_crime)
  (and
    (try
      (when (and (not (co-present ?victim @self))
                 (location ?victim): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (co-present ?victim @self))
                 (unknown (location ?victim))))
      (effects (maintain-proposal {@self go (home-of ?victim)})))
    (try
      (when (and (co-present ?victim @self)
                 (none {@self extort ?victim})))
      (utility errand always-pick)
      (effects (maintain-proposal
                 {@self SAY (utterable-msg (to ?victim) {@self extort ?victim}) ?victim})))
    (try
      (when (any {@self SAY ? ?victim /succ /caused_by ?coerce}))
      (effects
        (if (none {@self extort ?victim}) (then (begin-belief {@self extort ?victim})))
        (if (holds-coercion-material ?victim)
            (then (crime-ledger-append @self ?victim blackmail coerce @u @u))
            (else (crime-ledger-append @self ?victim threaten_violence coerce @u @u)))
        (set-outcome ?coerce succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?coerce fail)))))
