; ----------------------------------------------------------------------------
; fight_defence (npc-think) - the victim fights back (runtime-blame model, assault purged).
;
; A victim who WITNESSES a violent act against themselves - {?foe <any (theme violent_to)
; act> @self}, matched by the (theme-labels violent_to) comptime expansion, so it catches
; CHOKE / TRIGGER_FIREARM / any future violent act with no per-label edit - may engage.
; Their fight is CAUSED BY that witnessed act: "why were you fighting John? because John
; was throttling me." That cause is what exonerates the victim's own blows - appraisal
; suppresses wrong_act on a violent act that traces to an assault on its own actor, and the
; cause rides action->action across the perception boundary so bystanders exonerate them too.
;
; begin-proposal, not maintain: the witnessed blow is a transient act (one exchange), so a
; maintainer would flicker between blows; the latched fight persists across the brawl and
; concludes on its own twin (foe down / gone, in fight-task.hs). Combat resolve (volatility
; + sadism - compassion) gates whether this victim has the stomach to fight back at all.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think fight_defend
  (cooldown 1 m)

  ; Bind the aggressor + the witnessed violent act (the /caused_by handle); a believed-dead
  ; aggressor filters out.
  (role ?foe {?foe (theme-labels violent_to) @self}:?witnessed-rel
             (not {?foe condition [k dead]}))

  (when (chance (clamp (+ (attr @self volatility)
                          (attr @self sadism)
                          (- 1.0 (attr @self compassion)))
                       0.05 0.95)))

  (utility survival always-pick)

  (effects
    (begin-proposal {@self fight ?foe /caused_by ?witnessed-rel})))
