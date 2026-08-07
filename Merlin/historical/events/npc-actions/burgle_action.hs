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
       (at-place-kind [k building residential_building])))
; believes (not bind) so the effect-position call site below treats a jobless
; miss as plain false, never an effects abort.
(define-macro at-own-workplace ()
  (and (believes {@self job.org ?emp})
       (believes {?emp workplace ?work})
       (at-workplace ?work)))

; The theft action: PURE effects over what the pattern provides (?owner - the
; wronged party, resolved and vetted by burgle_strike) plus the physical scene
; (env reads only, no beliefs): the crime method keys on the PLACE (a residence
; is a break-in, anywhere else the authorized-presence embezzlement), the thief
; works the rooms and TAKES the first loose visible valuable (?took is the
; eval-local take-once flag), the ledger rows record it, and the residents get
; their chance to stir. The steal goal's conclusion (discharge + end-goal)
; belongs to steal_done (burgle_think.hs) - actions do no reasoning.
(npc-action {@self steal ?owner}
  (duration (if (at-place-kind [k building residential_building]) (then 15) (else 10)))
  (effects
    (bind (if (at-place-kind [k building residential_building])
              (then opportunist_theft)
              (else embezzle))
          ?method)
    (begin-ended-belief {@self ?method ?owner})
    (bind 0 ?took)
    (if (is-entity (current-building @self))
        (then
          (bind (current-building @self) ?scene)
          ; No hidden test on the loot: items are never hidden - a cached valuable
          ; sits in a hidden SUB-SPACE whose own contents index this rooms-only
          ; walk never reads.
          (for-each ?room (attr-values ?scene parts [k interior_space room])
            (for-each ?item (attr-values ?room contents)
              (if (and (= ?took 0) (has-facet ?item valuable))
                  (then
                    (take-item ?item)
                    ; carrying_loot is the trigger want_stow (stow.hs) reads to
                    ; MINT + OWN the {@self stow ?item} goal.
                    (begin-belief {@self carrying_loot ?item})
                    (crime-ledger-append @self ?owner ?method steal (kind ?item) @fail)
                    (bind 1 ?took)))))
          (if (= ?took 0)
              (then (crime-ledger-append @self ?owner ?method steal @fail @fail)))
          (burglary-confrontation @self ?scene)))
    (set-outcome {@self steal ?owner} succ)))
