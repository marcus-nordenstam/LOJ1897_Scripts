; ----------------------------------------------------------------------------
; coerce ?victim - press a threat on the victim to standing effect. @self reaches the
; victim and SAYs the threat aloud (the real auditory channel - the co-present victim
; ADOPTS {<speaker> extort @self}, the coercion anchor his own coercion-pressure reads;
; anyone else in earshot hears it too). NO fiat cross-mind write. @self also holds the
; ACTOR-side {@self extort ?victim} anchor in his OWN mind, which coercion_think then
; re-presses monthly. The deed is recorded by method - blackmail when @self holds
; leverage, else threaten_violence. The ended {@self coerce ?victim} belief IS the deed
; memory. No live victim -> abandon.
; ----------------------------------------------------------------------------

(task {@self coerce ?victim}:?coerce
  (track-skill-level [k illicit])
  (tar [k human] @object)
  (aux ?)
  (construed-act coercion-act wrong-act)
  (facets reportable_crime)
  (and
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (not (spatial ?victim co-located @self))
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self enter ?vhome}))))
    (try
      (when (and (or (spatial ?victim co-located @self) (spatial ?victim space))
                 -{@self extort ?victim}))
      (declare-utility errand always-pick)
      (effects (maintain-proposal {@self tell (utterable-msg [] {@self extort ?victim}) ?victim})))
    (try
      (when {@self tell ? ?victim /succ /caused_by ?coerce})
      (effects
        (if -{@self extort ?victim} (then (begin-belief {@self extort ?victim})))
        (if (or (any {?victim lover|HAVE-SEX-WITH ? /ever})
                (any {?victim extort|commission|hired-by|kill ? /ever}))
            (then (record-crime @self ?victim blackmail coerce @u @u))
            (else (record-crime @self ?victim threaten_violence coerce @u @u)))
        (set-outcome ?coerce /succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?coerce /fail)))))
