; ----------------------------------------------------------------------------
; found_business - the npc-ACT half of the business-founding split (Item 5).
;
; The decision (events/work/business.hs `business_founding`) minted {@self goal
; {@self found}}. These intra-day events drain it: the would-be proprietor
; goes to the bank to arrange his capital + file, and the business is FOUNDED there
; as the act's completion - leaving the founding documents (the detective clue
; trail) and the co-presence a witness would see, instead of a faceless world edit.
;
;   found_go     : hold the goal, not at a bank -> travel act to a same-town bank.
;   found_dwell  : hold the goal, AT the bank -> a dwell (arranging the founding).
;   found_commit : the dwell completion (completion-only) - leaves paid employment,
;                  founds the org (found-org spawns the workplace + installs him as
;                  proprietor + writes the articles), and clears the goal.
;
; Utility 85 beats the work lane (80) so a man set on founding pursues it rather
; than putting in another shift; it loses to night sleep (100) so he goes by day.
; A bank-less town yields k_fail -> found_go emits nothing and the goal waits; the
; town's business floor is held regardless by the (unsplit) business_homeostat.
; ----------------------------------------------------------------------------

; Arrival is gated on the KIND (at ANY bank), not a specific (venue ...) instance:
; (venue ...) random-picks a same-town bank per call, so it names a travel target
; for (go) but cannot be used to test arrival (each call could pick a different
; bank). Mirrors the drinking lane's (can-drink) at-a-pub gate.
(hsim-npc-behaviour found_go
  (short-term-think)
  (when (and (has-goal found)
             (not (at-place-kind [k building bank]))))
  (utility 85)
  (effects (go @self (venue [k building bank]))))

(hsim-npc-behaviour found_dwell
  (short-term-think)
  (when (and (has-goal found)
             (at-place-kind [k building bank])))
  (utility 85)
  (effects (begin-act {@self found} 90 found_commit)))

(hsim-npc-behaviour found_commit
  (on-completion)
  (effects
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
      (do
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
    (end-goal {@self found})))
