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
;   burgle_commit  : completion - the PURE .hs theft terminal (terminal-steal,
;                    perpetration_macros.hs) at the CURRENT premises: anchor +
;                    discharge + end-goal, take the first visible valuable, a
;                    stow goal to carry it home (stow.hs), the crime-ledger row,
;                    then the residents' chance to stir (burglary-confrontation).
;                    The task leaf is the context: embezzle at the thief's OWN
;                    workplace, opportunist_theft anywhere else. An ownerless /
;                    self-owned / dead-owner premises ends the goal (nothing
;                    there worth wronging) - the old commit-bail parity.
;
; Rate control is upstream: the deliberation's steal affinity weight x
; disinhibition x the master crime scalar decide who ever holds the goal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour burgle_go
  (short-term-think)
  (goal {@self steal})
  (rng-stream theft)
  (utility 85)
  (effects
    (bind (burgle-target @self) ?scene)
    (if ?scene
        (begin-act {@self go ?scene}))))

(hsim-npc-behaviour burgle_strike
  (short-term-think)
  (goal {@self steal})
  (when (and (not (at-home))
             (at-place-kind [k building residential_building])))
  (utility 86)
  (effects (begin-act {@self steal} 15 burgle_commit)))

(hsim-npc-behaviour embezzle_strike
  (short-term-think)
  (goal {@self steal})
  (when (and (bind {@self employer ?emp})
             (bind {?emp workplace ?work})
             (at-place ?work)))
  (utility 86)
  (effects (begin-act {@self steal} 10 burgle_commit)))

(hsim-npc-behaviour burgle_commit
  (on-completion)
  (effects
    (bind (current-building @self) ?scene)
    (if (is-entity ?scene)
        (do
          (bind (owner-of ?scene) ?owner)
          (bind (goal-belief steal) ?goal)
          (if (and (is-entity ?owner) (not (= ?owner @self)) (alive ?owner))
              (if (and (bind {@self employer ?emp})
                       (bind {?emp workplace ?work})
                       (at-place ?work))
                  (terminal-steal ?scene embezzle ?owner ?goal)
                  (terminal-steal ?scene opportunist_theft ?owner ?goal))
              (end-goal {@self steal}))))))
