; ----------------------------------------------------------------------------
; found_business (npc-action lane) - the ACT half of the business-founding split.
;
; The decision (events/work/business.hs `business_founding`) minted {@self goal
; {@self found}}. The would-be proprietor goes to the bank (npc-think lane) and the
; business is FOUNDED there as the act's completion - leaving the founding documents
; (the detective clue trail) and the co-presence a witness would see.
; ----------------------------------------------------------------------------

(npc-action found_act
  (act {@self found})
  (duration 90)
  (act-effects
    ; Roll a HOUSABLE business kind first (premises-aware: only kinds with a free
    ; building of their declared kind). If none can be housed right now, ?bizkind is
    ; a fail value and we found nothing this trip. No premises -> no founding -> no error.
    ; The foundable-business catalog, premises-gated (1): only a kind a free
    ; building of its declared premises kind can house right now is rolled -
    ; supply self-limits to what the authored level provides.
    (roll-org-kind (bind ?bizkind) 1
                   [k org grocer] [k org bookseller] [k org barbershop]
                   [k org restaurant] [k org pawnbroker] [k org apothecary]
                   [k org antiques_shop] [k org hotel])
    (if ?bizkind
      (then
        (fire /worker @self)
        ; mint the founding via the atomic-op sequence (proprietor head).
        (found-org-seq ?bizkind [k job proprietor])))
    ; Clear the goal regardless of the premises outcome. A dry-premises resolution
    ; LAPSES rather than persisting: were the goal kept on a dry roll, the founder
    ; would re-run found_dwell -> found_commit (and found_go) every intra-day cycle
    ; for as long as the town sat at premises capacity - a ~20k-fire/5yr storm. The
    ; resolution is re-minted at the proper deliberation cadence instead (annual
    ; business_founding / monthly business_homeostat), so a man whose town has no
    ; free premises simply tries again next window.
    (set-outcome {@self found} succ)))
