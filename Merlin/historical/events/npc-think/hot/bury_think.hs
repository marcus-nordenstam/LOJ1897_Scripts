; ----------------------------------------------------------------------------
; bury (think lane) - the priest's burial planning think. The rite act
; (bury_act) lives in npc-act/bury_act.hs.
;
; Burial is not a zero-role world sweep over every condition=dead corpse. A
; PRIEST (a real job-holder - the church org's head_pos, public_orgs.hs) buries
; the dead whose bodies are brought to his church. Knowledge reaches him by
; PERCEPTION, not telepathy: a bereaved NPC CARRIES the corpse into the church
; (convey_corpse.hs relocates the body into the church's room), and the priest,
; co-present in that room, PERCEIVES {<corpse> condition dead} on it directly
; (condition is a (per obs)(hsim-percept) attr, so mx_observe_interior_space
; mirrors it into his own mind as he walks the room's contents). No priest in a
; run (or a body nobody carries to a church) -> that corpse is simply never
; buried (accepted per the emergent-death-knowledge decision).
;
; TWO maintenance rungs, mutually exclusive on the co-present spatial gate (the
; enter.hs OUTSIDE-vs-INSIDE pattern), so the route->rite handoff is EMERGENT -
; no excl-goal, no per-trip arm flag. Both cast the priest (his OWN job belief,
; the CACHED self-gate, so every non-priest empty-set-skips the rung before the
; corpse/church pools materialize) and the most-overdue dead person he knows
; whose coroner window (>= 1 month, so a physician could examine the body -
; EXAMINE.act) has elapsed:
;
;   bury_route: while NOT co-present with the body, hold {@self enter ?church}
;     (the generic enter chain routes him into a church he knows - the graveyard
;     room the convey deposit files bodies into). CEASES the instant co-present
;     flips true (he has reached the body).
;   bury_onsite: while CO-PRESENT with the body, PROPOSE {@self BURY ?corpse}, whose
;     winning proposal promotes bury_act (the rite). The propose STOPS when the
;     corpse gate drops: bury_act tells {?corpse internment buried}, which @excl-
;     supersedes the priest's unburied percept, so the positive internment-unburied
;     filter unmatches and the ?corpse role empties (bury_act ends its own act-belief).
;
; The route->rite handoff is emergent from the co-present spatial gate: the held
; route rung advances to the rite the moment co-present flips, so the rite promotes
; the moment the priest reaches the body. Utility 85 on both - a solemn office duty
; that out-competes the priest's own day_work (80), else a deposited corpse lies
; unburied in the church for months.
;
; The corpse is cast off the ONGOING {?corpse condition dead} belief alone: a
; corpse's {isa human} belief is end-dated at death (propagate_death), so a
; [k human] positional kind - which compiles to a (believes {?corpse isa
; [k human]}) ongoing-belief filter - would never match. Only humans carry
; condition dead, so the filter is exact. The corpse is cast off the POSITIVE
; internment-unburied percept (every observer of a person holds it by default);
; bury_act mints {?corpse internment buried} in the burying priest's mind and
; TELLS the rite's co-present witnesses, and internment is @excl, so buried
; supersedes unburied and the positive filter drops it - no re-bury, no
; env-existence probe. A knower absent from the rite keeps the stale unburied
; percept until it fades (peripheral-object decay).
; ----------------------------------------------------------------------------

; ROUTE rung. Held while the priest is NOT yet co-present with the overdue body:
; roulette the nearest church he knows ONCE, hold {@self enter ?church} (the
; enter chain does the actual travel), and cease it on arrival (co-located flips
; true). No known church -> the rung never selects; a co-present body still
; buries via bury_onsite. The rouletted ?church is stashed at fire, so the hold
; and the cease operate on the SAME church (no re-roulette while walking).
(npc-think bury_route
  (role @self {@self job [k job priest]})
  (role ?corpse {?corpse condition [k dead]}
                {?corpse internment [k unburied]}
                (not (spatial ?corpse co-located @self))
                (select (score (months-since-death ?corpse)) (policy argmax)))
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when (>= (months-since-death ?corpse) 1))
  (utility obligation (above WORSHIP))
  (effects (maintain-proposal {@self enter ?church})))

; ONSITE rung. While the priest is CO-PRESENT with the overdue body, PROPOSE
; {@self BURY ?corpse} - the winning proposal promotes bury_act
; (the rite). bury_act ends its OWN {@self BURY ?corpse} act-belief and destroys the
; corpse (telling {?corpse internment buried}), so the ?corpse role empties on the next
; cycle and the rung simply stops proposing - no goal to retract, no cease needed.
(npc-think bury_onsite
  (role @self {@self job [k job priest]})
  (role ?corpse {?corpse condition [k dead]}
                {?corpse internment [k unburied]}
                (spatial ?corpse co-located @self)
                (select (score (months-since-death ?corpse)) (policy argmax)))
  (when (>= (months-since-death ?corpse) 1))
  (utility obligation (above WORSHIP))
  (effects (maintain-proposal {@self BURY ?corpse})))
