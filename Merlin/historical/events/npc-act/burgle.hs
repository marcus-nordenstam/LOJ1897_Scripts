; ----------------------------------------------------------------------------
; burgle (act lane) - the theft act + shared macros of the theft errand chain
; (the .hs port of the old C++ theft pass). The go/strike think rungs live in
; npc-think/burgle.hs. This file OWNS the at-burgle-residence / at-own-workplace
; macros (act lane loads first, so the think rungs can use them).
;
; Theft is PLACE-EMERGENT (the standing ruling): a thief can only steal by
; physically BEING at the scene - take it, leave, confrontation or not; there
; is no covert off-stage theft. The deliberation mints a FOCUSLESS {@self goal
; {@self steal}} from resource_scarcity (the scene is not a person; the
; perpetration steal place-lane binds loot AT the scene), and this chain acts
; on it:
;
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

; The two STRIKEABLE scenes for the steal goal: an occupied residence that is not
; the thief's own home (a break-in), or the thief's OWN workplace (embezzlement -
; authorized presence). burgle_go heads to a residence when at neither; at either,
; the steal goal is the leaf and promotes to steal_act.
(define-macro at-burgle-residence ()
  (and (not (at-home))
       (at-place-kind [k building residential_building])))
(define-macro at-own-workplace ()
  (and (bind {@self employer ?emp})
       (bind {?emp workplace ?work})
       (at-workplace ?work)))

; The theft act: the begun-then-ended {@self steal} act-belief IS the theft
; (15 min a break-in, 10 min an embezzlement). The completion is the PURE .hs
; theft terminal at the current premises.
(npc-act steal_act
  (when (believes {@self steal}))
  (duration (if (at-burgle-residence) 15 10))
  (act-effects
    (bind (current-building @self) ?scene)
    (if (is-entity ?scene)
        (do
          (bind (owner-of ?scene) ?owner)
          (bind (goal-belief steal) ?goal)
          (if (and (is-entity ?owner) (not (= ?owner @self)) (alive ?owner))
              (if (at-own-workplace)
                  (terminal-steal ?scene embezzle ?owner ?goal)
                  (terminal-steal ?scene opportunist_theft ?owner ?goal))
              (end-goal {@self steal}))))
    (end-act {@self steal})))
