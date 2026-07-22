; ----------------------------------------------------------------------------
; orient_errand - the npc-THINK half of orientation (approach the parish church to
; read its register). {@self orient} is a SHARED search goal owned by its minters
; (new_job_orientation, provision_orient, buy_home_find, list_to_let_find - each
; ceases when the org kind IT wants is learned). orient_go routes; at the church
; {@self orient} is the leaf and promotes to orient_act - no dwell rung.
; ----------------------------------------------------------------------------

(npc-think orient_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self orient})
  ; The church is role-cast from the churches the NPC KNOWS; nearest preferred,
  ; weighted. No known church -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building church] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building church])))
  (utility 28)
  (effects       (begin-goal {@self enter ?go_dest}))
  (cease-effects (end-goal   {@self enter ?go_dest})))

; AT a church: PROPOSE the orient act (goals never propose themselves). orient_act reads the
; register off the standing {@self orient} search goal, so the propose is label-only. One shared
; terminal for all four minting lanes (the marker is minter-agnostic).
(npc-think orient_at_church
  (schedule always)
  (goal {@self orient})
  (when (at-place-kind [k building church]))
  (utility 28)
  (effects (propose {@self orient})))
