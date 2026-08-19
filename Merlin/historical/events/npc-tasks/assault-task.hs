; ----------------------------------------------------------------------------
; assault (npc-task) - the perpetrator's blame-bearing attack episode (batch-3
; Lane 1, Marcus 2026-08-19). assault is where ALL the moral blame lives: it is
; (obs), so co-present witnesses OBSERVE {@self assault ?victim} on the running
; task (the observable-task perception channel) and know WHOM to blame - the
; subject of the assault, the aggressor. The blows themselves (the strike actions
; the fight proposes) are morally NEUTRAL; a defender who fights back is not
; "assaulting back" because the defender holds no assault task.
;
; The grand-daddy task: the confrontation FIGHT is caused by this one assault.
; assault reaches the victim, then begins {@self fight ?victim} /caused_by this
; assault; it stays open (the persistent parent) so the witnessed assault belief
; stands throughout the fight, and concludes bottom-up when the fight concludes.
;
; Proposed by the kill / hurt drivers (attempt_kill / discharge_hurt). NOT a
; construal minted by the victim - there is no victim-side assault belief; the
; witnessed copy IS the aggressor's own observable task.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-task {@self assault ?victim}:?assault
  (tar human)
  (obs)
  (construed_act harm_act wrong_act)
  (theme violent_to)
  (and
    ; REACH the victim: route to their location, or to their home if unknown.
    (try
      (when (and (not (co-present ?victim @self))
                 (location ?victim): ?loc))
      (utility survival)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (co-present ?victim @self))
                 (unknown (location ?victim))))
      (utility survival)
      (effects (maintain-proposal {@self go (home-of ?victim)})))

    ; CO-PRESENT: begin the confrontation, caused by THIS assault (the fight is
    ; the neutral episode; this assault is its one blame-bearing root).
    (try
      (when (and (co-present ?victim @self)
                 (not (believes {?victim condition [k dead]}))))
      (utility survival always-pick)
      (effects (begin-proposal {@self fight ?victim})))

    ; CONCLUDE bottom-up: the fight ended (victim dead / fled / broken off), so the
    ; assault episode is over. Also concludes if the victim is already dead (another
    ; hand felled them) - the assault is moot.
    (try
      (when (or (any {@self fight ?victim /succ})
                (believes {?victim condition [k dead]})))
      (effects (set-outcome ?assault succ)))))
