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
;   burgle_commit  : completion - the theft body at the CURRENT premises: the
;                    method anchor (embezzle at the thief's OWN workplace,
;                    opportunist_theft anywhere else - keyed on the place kind),
;                    take the first visible valuable, a stow goal to carry it
;                    home (stow.hs via carrying_loot), the crime-ledger row,
;                    then the residents' chance to stir (burglary-confrontation).
;                    An ownerless / self-owned / dead-owner premises never
;                    strikes (burgle_strike vets the owner); the steal goal's
;                    conclusion is steal_done's (burgle_think.hs).
;
; Rate control is upstream: the deliberation's steal affinity weight x
; disinhibition x the master crime scalar decide who ever holds the goal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The two STRIKEABLE scenes for the steal goal: an occupied residence that is not
; the thief's own home (a break-in), or the thief's OWN workplace (embezzlement -
; authorized presence). burgle_go heads to a residence when at neither; at either,
; the steal goal is the leaf and promotes to steal_action.
(define-macro at-burgle-residence ()
  (and (not (at-home))
       (is-a (building @self) [k building residential_building])))
; believes (not bind) so the effect-position call site below treats a jobless
; miss as plain false, never an effects abort.
(define-macro at-own-workplace ()
  (and (believes {@self job.org ?emp})
       (believes {?emp workplace ?work})
       (in-building @self ?work)))

; The theft is now the GENERIC take primitive: burgle_strike picks the loot
; and the wronged owner THINK-side and proposes {@self take_item ?loot ?owner};
; steal_done (burgle_think.hs) interprets the completed take as the theft
; (anchors, ledger, confrontation, discharge, goal end). The take body reads
; nothing beyond its pattern.
(npc-action {@self take_item ?loot ?owner}
  (duration 10)
  (effects
    (take-item ?loot)
    ; carrying_loot is the trigger want_stow (stow.hs) reads to MINT + OWN
    ; the {@self stow ?item} goal.
    (begin-belief {@self carrying_loot ?loot})
    (set-outcome {@self take_item ?loot ?owner} succ)))
