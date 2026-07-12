; ----------------------------------------------------------------------------
; bury (think lane) - the priest's burial planning think (plan_burial). The rite
; act (bury_act) lives in npc-act/bury.hs.
;
; Burial is no longer a zero-role world sweep over every condition=dead corpse.
; A PRIEST (a real job-holder - the church org's head_pos, public_orgs.hs)
; buries the dead whose bodies are brought to his church. Knowledge reaches him
; by PERCEPTION, not telepathy: a bereaved NPC CARRIES the corpse into the church
; (convey_corpse.hs relocates the body into the church's room), and the priest,
; co-present in that room, PERCEIVES {<corpse> condition dead} on it directly
; (condition is a (per obs)(hsim-percept) attr, so mx_observe_interior_space
; mirrors it into his own mind as he walks the room's contents). No priest in a
; run (or a body nobody carries to a church) -> that corpse is simply never
; buried (accepted per the emergent-death-knowledge decision).
;
;   plan_burial (think): the priest casts the most-overdue dead person he knows
;     (a corpse he has perceived) whose coroner window (>= 1 month, so a
;     physician could examine the body - EXAMINE.act) has elapsed. When he is
;     CO-PRESENT with the body (it is in his room now) he holds the on-site
;     {@self bury <corpse>} act-goal; otherwise he routes to a church he knows
;     (the graveyard) to stand with it again.
;
; The corpse is cast off the ONGOING {?corpse condition dead} belief alone: a
; corpse's {isa human} belief is end-dated at death (propagate_death), so a
; [k human] positional kind - which compiles to a (believes {?corpse isa
; [k human]}) ongoing-belief filter - would never match. Only humans carry
; condition dead, so the filter is exact. A corpse already buried (env entity
; destroyed) reads (months-since-death) = 0 via the boundary liveness gate, so
; the coroner-window gate self-excludes it - no re-bury, no stale read.
; ----------------------------------------------------------------------------

; The priest's standing duty. Casts a stale corpse he has perceived; when the
; body is with him he holds the on-site bury goal, else routes to his church.
; Utility = a work obligation (a solemn office duty that out-competes routine
; work). cont-fire re-asserts the routing/act excl-goal each cycle; when the
; corpse is buried (destroyed) the coroner-window gate falls false and co-present
; goes false, so the goal is swept.
(npc-think plan_burial
  (short-term-think)
  ; The most-overdue dead person the priest knows (perceived in his church).
  (role ?corpse (believes {?corpse condition [k dead]})
                (select (score (months-since-death ?corpse)) (policy argmax)))
  ; The nearest church he KNOWS (his own workplace / graveyard). No known church
  ; -> the routing branch no-ops; a co-present body still buries where he stands.
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  ; A priest (his OWN job belief - no scan), and the coroner window has passed.
  (when (and (believes-obj-kind job [k job priest])
             (>= (months-since-death ?corpse) 1)))
  (utility 55)
  (cont-fire-effects
    ; CO-PRESENT with the body (it is in his room now) -> perform the rite. Else
    ; route to a church he knows and stand with it again.
    (if (co-present @self ?corpse)
        (excl-goal {@self bury ?corpse})
        (if (and (is-entity ?church) (not (= ?church @self)))
            (excl-goal {@self go ?church})))))
