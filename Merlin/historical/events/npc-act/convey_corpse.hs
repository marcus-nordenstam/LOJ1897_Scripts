; ----------------------------------------------------------------------------
; convey_corpse - the bereaved-kin lane that CARRIES a dead relative's body to a
; church. Pure perception, no telepathy: nobody writes the priest's mind. The
; body physically ends up in the church's room, and a co-present priest PERCEIVES
; the corpse there (bury.hs). The corpse's presence in the church IS the "bury
; me" marker - no blackboard, no (tell), no report doc.
;
; When someone dies, propagate_death re-asserts an ongoing {<corpse> condition
; dead} belief (k_unforgettable) in every mind of the deceased's social circle
; (kin / friends / adversaries) - and end-dates every OTHER belief about them,
; incl. {<corpse> isa human}. So a bereaved NPC KNOWS the death (his own genuine
; knowledge) but the priest does not yet. This lane closes that gap PHYSICALLY:
; the bearer brings the body to a church, where the priest can see it.
;
; Structure mirrors the drink / worship B4 lanes (one desire, case sub-goals):
;   want_convey  (desire): a grown, decent NPC who holds a not-yet-delivered
;     death belief holds {@self convey ?corpse}. Utility x politeness (respect
;     for the observances), capped as an errand.
;   AT a church (case A): {@self convey ?corpse} has no live sub-goal, so it is
;     the leaf and promotes straight to convey_act (the deposit). No rule needed.
;   know a church (case B): convey_go holds {@self go ?church} /cause the goal.
;   know none  (case C): convey_find holds {@self find_building [k church]}.
;
; The go / find sub-goals fire only while NOT at a church; at a church neither is
; live, so the convey goal is the leaf and convey_act runs - the same implicit
; location gate the drink lane uses (drink_act only runs at a pub).
;
; The corpse is cast off the ONGOING {?corpse condition dead} belief alone (no
; [k human] positional kind: that would compile to a (believes {?corpse isa
; [k human]}) filter, and propagate_death has end-dated that belief - only the
; condition-dead belief is still ongoing on a corpse). Only humans ever carry
; condition dead, so the filter is exact. The one-shot {@self conveyed ?corpse}
; marker bars re-carting the SAME body (the role's (not (believes ...)) drops
; it): one church-trip per known death, not a standing pilgrimage. A corpse
; already buried elsewhere (env entity destroyed) reads (months-since-death) = 0
; and the relocate is a safe no-op on its dead abs link.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The DESIRE - the ONLY place the errand pressure is computed. Casts the most-
; overdue death this NPC knows AND has not yet delivered; argmax keeps the target
; stable while routing. Utility x politeness, capped modest (an errand, not a
; life-goal). cont-fire re-asserts the convey goal each cycle (an excl-goal is
; swept the moment a cycle stops re-stamping it).
(npc-think want_convey
  (short-term-think)
  (role @self (grown @self))
  (role ?corpse (believes {?corpse condition [k dead]})
                (not (believes {@self conveyed ?corpse}))
                (select (score (months-since-death ?corpse)) (policy argmax)))
  (when    (>= (attr @self politeness) 0.3))
  (utility (* (attr @self politeness) 40))
  (cont-fire-effects (excl-goal {@self convey ?corpse})))

; CASE B - not at a church, but knows one: head to it. The (goal ...) clause pins
; the convey goal as this rule's parent, so the go sub-goal inherits the drive and
; auto-links its /cause - no hand-written /cause.
(npc-think convey_go
  (short-term-think)
  (goal    {@self convey ?corpse})
  (role @self (grown @self))
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when    (not (is-a (current-building @self) [k building church])))
  (cont-fire-effects (excl-goal {@self go ?church})))

; CASE C - not at a church and knows none: search for one (find_building.hs runs it).
(npc-think convey_find
  (short-term-think)
  (goal    {@self convey ?corpse})
  (fatigue-timeout 90)                                 ; ~90 min of searching a day, then rest
  (role @self (grown @self))
  (no-role [k building church])
  (when    (not (is-a (current-building @self) [k building church])))
  (cont-fire-effects (excl-goal {@self find_building [k building church]})))

; CASE A (deposit): at a church the convey goal is the leaf and promotes here.
; (relocate ?corpse <church>) files the body into the church's room contents (the
; env placement seam derives its {?corpse location <room>}); a co-present priest
; then PERCEIVES {?corpse condition dead} there - no telepathy. The one-shot
; marker bars re-carting; ending the act-belief makes the deposit fire exactly
; once. Depositing a corpse already gone (buried elsewhere) is a safe no-op.
(npc-act convey_act
  (when (believes {@self convey ?corpse}))
  (duration 15)
  (act-effects
    (relocate ?corpse (current-building @self))
    (begin-belief {@self conveyed ?corpse})
    (end-act {@self convey ?corpse})))
; go_act (the shared travel act) lives in npc-act/go.hs.
