; ----------------------------------------------------------------------------
; convey_corpse (npc-think lane) - the bereaved-kin lane that CARRIES a dead
; relative's body to a church. Pure perception, no telepathy: nobody writes the
; priest's mind. The body physically ends up in the church's room (deposit act in
; npc-act/convey_corpse.hs), and a co-present priest PERCEIVES the corpse there
; (bury.hs). The corpse's presence in the church IS the "bury me" marker - no
; blackboard, no (tell), no report doc.
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
;     death belief holds {@self CONVEY ?corpse}. Utility x politeness (respect
;     for the observances), capped as an errand.
;   AT a church (case A): convey_at_church proposes {@self CONVEY ?corpse} - the leaf
;     label promotes to convey_act (the deposit); the bare goal never self-promotes.
;   know a church (case B): convey_go holds {@self go ?church} /caused_by the goal.
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
; condition dead, so the filter is exact. The ended {@self CONVEY ?corpse}
; act-belief bars re-carting the SAME body (the role's (not (believes ...)) drops
; it): one church-trip per known death, not a standing pilgrimage. A corpse
; already buried elsewhere is excluded belief-side for everyone who attended or
; was told of the rite (bury_act's (tell {?corpse condition [k buried]}) drops
; it from the dead-and-not-buried cast); an absent knower's stale dead-belief
; fades on the normal decay curve, and the relocate stays a safe no-op on a
; dead abs link meanwhile.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The DESIRE - the ONLY place the errand pressure is computed. Casts the most-
; overdue death this NPC knows AND has not yet delivered; argmax keeps the target
; stable while routing. Utility x politeness, capped modest (an errand, not a
; life-goal). A maintenance minter: it mints the standing convey goal and holds it;
; once the deposit ends {@self CONVEY ?corpse} /succ the role stops casting the corpse,
; the gate drops, and the convey goal ends.
(npc-think want_convey
  (role @self (grown @self))
  (role ?corpse {?corpse condition [k dead]}
                (not {?corpse condition [k buried]})
                (not {@self CONVEY ?corpse /past})
                (select (score (months-since-death ?corpse)) (policy argmax)))
  ; FRESHNESS cap beside the politeness gate: a death known for months no longer
  ; motivates the errand (someone has surely dealt with it) - the belt-and-braces
  ; bound on the standing-corpse scan where the burial propagation missed a
  ; knower (an emigrant, a returnee).
  (when    (and (observed ?corpse)
                (>= (attr @self politeness) 0.3)
                (< (months-since-death ?corpse) 6)))
  ; x85, a shade OVER want_worship's x80: burying your dead outranks attending a
  ; service, so at the church the deposit wins the first slot and the service
  ; follows (at x80 the two tied and the deposit lost the tie for years).
  (utility (* (attr @self politeness) 85))
  (effects       (begin-goal {@self CONVEY ?corpse}))
  (cease-effects (end-goal   {@self CONVEY ?corpse})))

; TERMINAL step (act_body_purification): the deposit is PROPOSED, guarded by being IN a church
; (the deposit's own precondition). Because `convey` is a proposed label the {@self CONVEY ?corpse}
; desire drops out of the auction (it still persists + drives convey_go/find), so convey promotes
; ONLY here, ONLY at a church - no off-church fall-through that would file the body wherever the
; bearer stood.
(npc-think convey_at_church
  (goal    {@self CONVEY ?corpse})
  (role @self (grown @self))
  (when    (is-a (building @self) [k building church]))
  (utility (* (attr @self politeness) 85))
  (effects (maintain-proposal {@self CONVEY ?corpse})))

; CASE B - not at a church, but knows one: head to it. The (goal ...) clause pins
; the convey goal as this rule's parent, so the go sub-goal inherits the drive and
; auto-links its /caused_by - no hand-written /caused_by.
(npc-think convey_go
  (goal    {@self CONVEY ?corpse})
  (role @self (grown @self))
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when    (not (is-a (building @self) [k building church])))
  (effects (maintain-proposal {@self enter ?church})))

; CASE C - not at a church and knows none: search for one (find_building.hs runs it).
(npc-think convey_find
  (goal    {@self CONVEY ?corpse})
  (role @self (grown @self))
  (no-role [k building church])
  ; Search while no church is known and the region is not yet proven churchless (find_building's
  ; /fail fires only once the whole region is covered without finding one).
  (when    (and (not (is-a (building @self) [k building church]))
                (not (did-fail {@self find_building [k building church] /past}))))
  (effects (maintain-proposal {@self find_building [k building church] (current-region @self)})))
