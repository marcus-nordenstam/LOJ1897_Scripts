; ----------------------------------------------------------------------------
; found_business (npc-think lane) - the THINK half of the business-founding split.
;
; The decision (business_think.hs `business_founding`) minted {@self goal {@self
; found}} and OWNS its whole life (it ceases when found_business_act seats him as a
; proprietor/org_head). found_go routes the would-be proprietor to a same-town bank;
; AT the bank found_go ceases and the goal is the leaf and promotes to
; found_business_act, which arranges his capital, files, and FOUNDS the business there
; - no dwell rung.
;
; Utility 85 beats the work lane (80) so a man set on founding pursues it rather
; than putting in another shift; it loses to night sleep (100) so he goes by day.
; A bank-less town yields k_fail -> found_go emits nothing and the goal waits; the
; town's business floor is held regardless by business_homeostat.
; ----------------------------------------------------------------------------

; Arrival is gated on the KIND (at ANY bank), not a specific (venue ...) instance:
; (venue ...) random-picks a same-town bank per call, so it names a travel target
; for (go) but cannot be used to test arrival (each call could pick a different
; bank). Mirrors the drinking lane's (can-drink) at-a-pub gate.
(npc-think found_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self found})
  ; The bank is role-cast from the banks the NPC KNOWS (naked [k ..] = (believes
  ; {?this isa [k ..]})); the nearest is preferred, weighted so the town spreads.
  ; No known bank -> the role binds nothing and found_go does not fire (the goal
  ; waits). Replaces the omniscient (venue ...) pick.
  (role ?go_dest [k building bank] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building bank])))
  (utility 85)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))

; AT a bank: PROPOSE the founding act (goals never propose themselves). found_business_act reads
; its capital / articles off the standing {@self found} goal focus, so the propose is label-only.
(npc-think found_at_bank
  (schedule always)
  (goal    {@self found})
  (when    (at-place-kind [k building bank]))
  (utility 85)
  (effects (maintain-proposal {@self found})))
