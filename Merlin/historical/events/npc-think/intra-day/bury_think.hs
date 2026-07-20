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
; condition dead, so the filter is exact. An already-buried corpse is excluded
; belief-side: bury_act mints {?corpse condition buried} (kept ONGOING beside
; `dead` - condition is non-exclusive) in the burying priest's mind and TELLS
; the rite's co-present witnesses, so the (not (believes ... buried)) filter
; drops it - no re-bury, no env-existence probe. A knower absent from the rite
; keeps the stale dead-belief until it fades (peripheral-object decay).
; ----------------------------------------------------------------------------

; The priest's standing duty. Casts a stale corpse he has perceived; when the
; body is with him he holds the on-site bury goal, else routes to his church.
; Utility = a work obligation (a solemn office duty that out-competes routine
; work). cont-fire re-asserts the routing/act excl-goal each cycle; when the
; corpse is buried (destroyed) the coroner-window gate falls false and co-present
; goes false, so the goal is swept.
(npc-think plan_burial
  (short-term-think)
  ; A priest (his OWN job belief) - the CACHED self-gate, so every non-priest
  ; empty-set-skips the whole think before the corpse/church pools materialize.
  (role @self (believes {@self job [k job priest]}))
  ; The most-overdue dead person the priest knows (perceived in his church).
  (role ?corpse (believes {?corpse condition [k dead]})
                (not (believes {?corpse condition [k buried]}))
                (select (score (months-since-death ?corpse)) (policy argmax)))
  ; The nearest church he KNOWS (his own workplace / graveyard). No known church
  ; -> the routing branch no-ops; a co-present body still buries where he stands.
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  ; The coroner window has passed.
  (when (>= (months-since-death ?corpse) 1))
  ; 85: must out-compete the priest's own day_work (80) - the stated intent
  ; ("a solemn office duty that out-competes routine work"); at 55 the bury act
  ; almost never won the motor and deposited corpses lay in the church for months.
  (utility 85)
  (cont-fire-effects
    ; CO-PRESENT with the body (it is in his room now) -> perform the rite. Else
    ; route INTO a church he knows ((go-into): front-park, then ENTER its entry
    ; room - the same room the convey deposit files bodies into). A bare
    ; (go ?church) only FRONT-PARKS a building post-Stage-5, leaving the priest
    ; at the door where room-level co-presence with the corpse can never hold.
    (if (co-present @self ?corpse)
        (excl-goal {@self bury ?corpse})
        (if (is-entity ?church)
            (excl-goal {@self enter ?church})))))
