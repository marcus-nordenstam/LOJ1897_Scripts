; ----------------------------------------------------------------------------
; burgle.hs - the theft errand chain (the .hs port of the old C++ theft pass).
;
; Theft is PLACE-EMERGENT (the standing ruling): a thief can only steal by
; physically BEING at the scene - take it, leave, confrontation or not; there
; is no covert off-stage theft. The deliberation mints a FOCUSLESS {@self goal
; {@self steal}} from resource_scarcity (the scene is not a person; the
; perpetration steal place-lane binds loot AT the scene), and this chain acts
; on it:
;
;   burgle_go      : hold the steal goal -> pick an occupied non-home same-town
;                    residence ((burgle-target), env-truth like (venue)) and
;                    travel there. No scene qualifies -> no act (try again at a
;                    later deliberation).
;   burgle_strike  : standing in a residence that is not my own with the goal
;                    -> the short theft act. Outbids burgle_go by one point, so
;                    arrival flips travel into the strike.
;   embezzle_strike: the employed thief at their OWN workplace - authorized
;                    presence, no break-in. The place-lane's embezzle method
;                    (has_authority_over) or shop-floor opportunist_theft
;                    commits there; the work itinerary supplies the presence.
;   burgle_commit  : completion - (commit-theft @self) runs the perpetration
;                    steal place-lane at the CURRENT premises: method row x
;                    transfer_property terminal, crime-ledger row, goal ended.
;
; Rate control is upstream: the deliberation's steal affinity weight x
; disinhibition x the master crime scalar decide who ever holds the goal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event burgle_go
  (intra-day)
  (rng-stream theft)
  (when (has-goal steal))
  (utility 85)
  (effects
    (bind (burgle-target @self) ?scene)
    (if ?scene
        (go @self ?scene))))

(hsim-event burgle_strike
  (intra-day)
  (when (and (has-goal steal)
             (not (at-home))
             (at-place-kind [k building residential_building])))
  (utility 86)
  (effects (act burgle_commit 15)))

(hsim-event embezzle_strike
  (intra-day)
  (when (and (has-goal steal)
             (bind {@self employer ?emp})
             (bind {?emp workplace ?work})
             (at-place ?work)))
  (utility 86)
  (effects (act burgle_commit 10)))

(hsim-event burgle_commit
  (schedule (completion-only))
  (effects (commit-theft @self)))
