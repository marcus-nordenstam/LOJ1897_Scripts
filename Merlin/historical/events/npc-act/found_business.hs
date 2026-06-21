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
(hsim-event found_go
  (intra-day)
  (nl   "@self sets out to arrange a business")
  (when (and (has-goal found)
             (not (self-at [k building bank]))))
  (utility 85)
  (effects (go @self (venue [k building bank]))))

(hsim-event found_dwell
  (intra-day)
  (nl   "@self arranges his business at the bank")
  (when (and (has-goal found)
             (self-at [k building bank])))
  (utility 85)
  (effects (act found_commit 90)))

(hsim-event found_commit
  (schedule (completion-only))
  (nl   "@self founds a business")
  (effects
    (fire :worker @self)
    (found-org :kind business :founder @self)
    (clear-goal @self found)
    (log _business_founding @self)))
