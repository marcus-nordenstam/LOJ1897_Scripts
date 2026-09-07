; ----------------------------------------------------------------------------
; fight_defence (npc-think) - the victim fights back (runtime-blame model, assault purged).
;
; A victim who WITNESSES a violent act against themselves - {?foe <any (theme violent-to)
; act> @self}, matched by the (theme-labels violent-to) comptime expansion, so it catches
; CHOKE / TRIGGER_FIREARM / any future violent act with no per-label edit - may engage.
; Their fight is CAUSED BY that witnessed act: "why were you fighting John? because John
; was throttling me." That cause is what exonerates the victim's own blows - appraisal
; suppresses wrong-act on a violent act that traces to an assault on its own actor, and the
; cause rides action->action across the perception boundary so bystanders exonerate them too.
;
; MAINTAINED on the RECORD of the blow (/ever), not the blow itself - a transient act would
; flicker the maintainer between exchanges; the fight then persists across the brawl and
; concludes on its own twin (foe down / gone, in fight-task.hs), which ends the bout. The
; concluded-fight guard keeps one old blow from raising a new fight every period. Combat resolve (volatility
; + sadism - compassion) gates whether this victim has the stomach to fight back at all.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think fight_defend
  (cooldown 1 m)

  ; Bind the aggressor + the witnessed violent act (the /caused_by handle); a believed-dead
  ; aggressor filters out.
  (role ?foe {?foe (theme-labels violent-to) @self /ever}:?witnessed-rel
             -{?foe condition [k dead]}
             -{@self fight ?foe /succ /caused_by ?witnessed-rel}
             -{@self fight ?foe /fail /caused_by ?witnessed-rel})

  (when (latch-eval (chance (clamp (+ (attr @self volatility)
                          (attr @self sadism)
                          (- 1.0 (attr @self compassion)))
                       0.05 0.95))))

  (utility survival always-pick)

  (effects
    (maintain-proposal {@self fight ?foe /caused_by ?witnessed-rel})))
