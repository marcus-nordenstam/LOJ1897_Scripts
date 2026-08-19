; ----------------------------------------------------------------------------
; fight_defence (npc-think) - the victim fights back (batch-3 Lane 1).
;
; A victim who OBSERVES {?foe assault @self} - the aggressor's observable assault
; task, internalized by @self's perception of him assaulting (no victim-side
; construal, no under_attack state) - may engage. Their fight is caused by that
; WITNESSED assault: "why were you fighting John? because John assaulted me." The
; defender holds NO assault task, so their blows carry no blame; the blame stays on
; the aggressor, the subject of the assault they trace back to.
;
; MAINTAIN, not begin: the fight is held only while @self still perceives the
; assault and their combat resolve (volatility + sadism - compassion, re-rolled each
; round) carries it. When the aggressor is felled or breaks off, his assault task
; stops, @self's perception disproves the witnessed belief, the role empties and the
; defence drops - the threat-over is automatic, no explicit end. A wavering victim
; trades some rounds and falters others (a lost resolve roll leaves no fight, and -
; when the flee / scream lanes land - yields the round to them).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think fight_defend
  (cooldown 1 m)

  ; Bind the aggressor off the witnessed assault, and the belief itself for the cause;
  ; a believed-dead aggressor filters out in the role (cached, wake-driven).
  (role ?foe {?foe assault @self}:?witnessed_assault
             (not (believes {?foe condition [k dead]})))

  (when (chance (clamp (+ (attr @self volatility)
                          (attr @self sadism)
                          (- 1.0 (attr @self compassion)))
                       0.05 0.95)))

  (utility survival always-pick)

  (effects
    (maintain-proposal {@self fight ?foe} /caused_by ?witnessed_assault)))
