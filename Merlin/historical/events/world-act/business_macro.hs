; business_macro - the town-level business floor/failure regulators (world-act, zero-role). The merit-founding THINKS (investment/partnership/founding) are in npc-think/business.hs.
; (Split from the original lane file in the npc-think/npc-act reorg.)

(hsim-event business_failure
  (nl         "businesses fail in hard times")
  (schedule   (annually december))
  (rng-stream business)

  (effects
    (fail-businesses 0.02)))

; --- business_homeostat: org-supply floor (Phase 2) -------------------------
; A ZERO-ROLE homeostat (see business_failure's header for the zero-role
; rationale - found-businesses scans and CREATES entities, which must not run
; inside a role-enumeration mx_for_each_entity walk). Keeps the town's business
; count near one per dozen souls, founding new ones while below that floor.
;
; This is what sustains EMPLOYMENT across generations. The merit-gated founding
; events above require the founder to ALREADY be employed and monied, so once
; the seed businesses die out the eligible pool empties, founding stops, and
; employment bleeds to zero (observed: founding ends ~cycle 42, employment by
; ~cycle 208). found-businesses founds from any alive adult of founding age,
; breaking that chicken-and-egg; the existing `hiring` event then staffs the
; new businesses from the jobless.
(hsim-event business_homeostat
  (nl         "the town's commerce keeps pace with its people")
  (schedule   (annually january))
  (rng-stream business)

  (effects
    (found-businesses 12)))
