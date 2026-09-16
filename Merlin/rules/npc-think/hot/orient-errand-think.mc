; ----------------------------------------------------------------------------
; orient_errand - the npc-THINK half of orientation (approach the parish church to
; read its register). {@self ORIENT} is a SHARED search goal owned by its minters
; (new_job_orientation, provision_orient, buy_home_find, list_to_let_find - each
; ceases when the org kind IT wants is learned). orient_go routes; at the church
; {@self ORIENT} is the leaf and promotes to orient_act - no dwell rung.
; ----------------------------------------------------------------------------

(npc-think orient_go
  (goal {@self ORIENT})
  ; The church is role-cast from the churches the NPC KNOWS; nearest preferred,
  ; weighted. No known church -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building church] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (is-a (spatial @self building) [k building church])))
  (effects (maintain-proposal {@self enter ?go_dest})))

; AT a church: PROPOSE the orient act (goals never propose themselves). orient_act reads the
; register off the standing {@self ORIENT} search goal, so the propose is label-only. One shared
; terminal for all four minting lanes (the marker is minter-agnostic).
(npc-think orient_at_church
  (goal {@self ORIENT})
  (when (is-a (spatial @self building) [k building church]))
  (effects (maintain-proposal {@self ORIENT})))
