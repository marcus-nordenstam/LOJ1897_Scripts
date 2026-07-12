; ----------------------------------------------------------------------------
; orient_errand - the npc-THINK half of new_job_orientation (approach a church).
; The worker holds {@self orient}: route to the parish church, then dwell there
; (the register read happens in orient_act).
; ----------------------------------------------------------------------------

(npc-think orient_go
  (short-term-think)
  (goal {@self orient})
  ; The church is role-cast from the churches the NPC KNOWS; nearest preferred,
  ; weighted. No known church -> no fire (the goal waits). Replaces (venue ...).
  (role ?go_dest [k building church] (select (score (near @self ?go_dest)) (policy roulette)))
  (when (not (at-place-kind [k building church])))
  (utility 28)
  (cont-fire-effects (go-into ?go_dest)))

(npc-think orient_dwell
  (short-term-think)
  (goal {@self orient})
  (when (at-place-kind [k building church]))
  (utility 28)
  (cont-fire-effects (begin-goal {@self orient})))
