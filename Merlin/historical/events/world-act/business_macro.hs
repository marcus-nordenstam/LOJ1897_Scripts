; business_macro - the town-level business FAILURE regulator (world-act, zero-role).
; The merit-founding THINKS (investment/partnership/founding) AND the non-merit floor
; net (business_homeostat) are per-NPC events in npc-think/business.hs.

(hsim-world-event business_failure
  (schedule   (annually december))
  (rng-stream business)

  (effects
    (fail-businesses 0.02)))
