; ----------------------------------------------------------------------------
; means - a kill-method's MEANS acquired by PLAN-AS-YOU-GO (4.13 C/D/G).
;
; The generalization of the Phase C poison cascade to ALL weapon-gated kill
; methods: a killer whose chosen method needs a tool in hand (poison->toxin,
; shoot->firearm, stab->blade, garrotte->cord_or_wire ...) DERIVES and EXECUTES
; the errand to obtain it, instead of the tool being conjured at strike time.
;
; The required tool is the killer's OWN {@self method_means [k <control>]} belief
; (choose_kill_method.hs), bound as a plain ?means - a normal own-mind read, no
; magic runtime atom. The chain:
;   1. has a method_means it does not yet control -> push utility onto the standing
;      acquire goal {@self acquire [k <means>]} (a real belief - the killer's own
;      memory of setting out to arm) so it promotes to acquire_act;
;   2. acquire_act dwells the round-trip travel time, then (at completion) acquires
;      a REAL item of that kind into the killer's hand (acquire-control ->
;      acquire_weapon sets controlled_by) - IF the kill is still intended - and
;      ends the acquire goal. The tool KIND flows via the act-belief target, so it
;      survives to the completion pass (unlike a per-deliberation global would).
; Once armed the desire stops firing (real-possession termination); the existing
; kill path consumes the held tool via its (control_any ...) requirement.
;
; Possession is the REAL model (States.mon axis (b) controlled_by / hold), not an
; invented belief. The world-write (acquire-control) fires in the completion pass.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The obtain act: the acquire goal, the leaf, promotes here. A DURATIVE dwell of the
; round-trip travel time to fetch the tool; the world-write lands at COMPLETION.
; DEMAND RE-VALIDATION: the obtain is a sub-act serving a kill the actor still
; intends - re-check (goal? {@self kill}) at completion, so a kill that lapsed
; while the actor travelled (the victim died, the grudge faded) does NOT arm.
(npc-act acquire_act
  (when (bind {@self acquire ?m}))
  (duration (travel-minutes @self ?m))
  (act-effects
    (if (goal? {@self kill})
        (acquire-control @self ?m))
    (end-act {@self acquire ?m})
    (end-goal {@self acquire ?m})))

; NB: the kill STRIKE terminal (means_strike) was moved to
; historical/_unported_events/means_strike.hs when the place-lane crime passes were
; retired - re-port it as a co-presence cascade terminal alongside the kill behaviour.
