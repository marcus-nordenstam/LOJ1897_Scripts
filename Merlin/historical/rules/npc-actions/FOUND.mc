; ----------------------------------------------------------------------------
; found_business (npc-action lane) - the ACT half of the business-founding split.
;
; The decision (rules/work/business.hs `business_founding`) minted {@self goal
; {@self FOUND}}. The would-be proprietor goes to the bank (npc-think lane) and the
; business is FOUNDED there as the act's completion - leaving the founding documents
; (the detective clue trail) and the co-presence a witness would see.
; ----------------------------------------------------------------------------

(npc-action {@self FOUND}
  (duration 90)
  (effects
    ; Roll a kind from the authored catalog. found-org-seq's own premises guard
    ; no-ops the founding when no free building of that kind's declared premises
    ; exists, so a dry pool costs a trip and nothing else.
    (table-sample-weighted foundable_businesses kind weight): ?bizkind
    (if ?bizkind
      (then
        (fire-self)
        ; mint the founding via the atomic-op sequence (proprietor head).
        (found-org-seq ?bizkind [k job proprietor])))
    ; Clear the goal regardless of the premises outcome. A dry-premises resolution
    ; LAPSES rather than persisting: were the goal kept on a dry roll, the founder
    ; would re-run found_dwell -> found_commit (and found_go) every intra-day cycle
    ; for as long as the town sat at premises capacity - a ~20k-fire/5yr storm. The
    ; resolution is re-minted at the proper deliberation cadence instead (annual
    ; business_founding / monthly business_homeostat), so a man whose town has no
    ; free premises simply tries again next window.
    (set-outcome {@self FOUND} /succ)))
