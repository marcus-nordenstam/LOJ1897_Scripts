; ----------------------------------------------------------------------------
; frame ?victim - fabricate evidence against the framed party. @self walks to the
; victim's home and PLANTS a forged_letter there - a real, discoverable/witnessable
; object left at the scene (decision 3: a placed object, not a fiat yield-evidence
; stain). A later search / detective finds it and reads the victim as implicated. The
; ended {@self frame ?victim} belief IS the deed memory; the crime-ledger row records it.
; A dead victim, or one whose home @self cannot place, -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self frame ?victim}:?frame-rel
  (tar human)
  (aux ?)
  (construed_act harm_act betray_act wrong_act)
  (facets reportable_crime)
  (and
    (try
      (when (and (alive ?victim)
                 (any {?victim home ?home})
                 (not (spatial @self building ?home))))
      (utility errand)
      (effects (maintain-proposal {@self go ?home})))
    (try
      (when (and (alive ?victim)
                 (any {?victim home ?home})
                 (spatial @self building ?home)
                 (none {@self frame ?victim /succ /ever})))
      (utility errand always-pick)
      (effects
        (plant-letter [k forged_letter]
                      (nl-written-msg "?victim killed me") (spatial @self space))
        (crime-ledger-append @self ?victim plant_evidence frame @u @u)
        (set-outcome ?frame-rel /succ)))
    (try
      (when (or (not (alive ?victim))
                (not (any {?victim home ?}))))
      (effects (set-outcome ?frame-rel /fail)))))
