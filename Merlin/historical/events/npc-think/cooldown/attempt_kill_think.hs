; ----------------------------------------------------------------------------
; attempt_kill (npc-think) - the kill goal's execution routing (batch-3 Lane 1).
;
; A standing {@self goal {@self kill V}} runs through the ASSAULT -> FIGHT
; decomposition: this rung PROPOSES the blame-bearing {@self assault V} task
; (assault-task.hs), which reaches V and begins the neutral {@self fight V}
; episode; the fight proposes the chosen strike action blow by blow until V dies.
; The assault carries the moral blame (it is (obs), witnessed); the blows do not.
;
; kill_concluded is the goal's dead-twin: goal retirement is distributed now (the
; central propagate-death goal-sweep is purged), so the standing kill goal ends
; itself the moment @self believes V dead (his own fatal blow minted the
; dead-percept; or another hand felled V and he learned by a real channel).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think attempt_kill
  (cooldown 1 m)
  (goal {@self kill ?victim}:?kgoal)

  (role @self )

  ; ?victim = the standing kill-goal focus. A kind-valued profile goal or a dead
  ; victim gates out; begin-proposal dedups a matching live assault proposal (no
  ; self-felling no-goal gate needed).
  (when (and ?victim
             (none {?victim condition [k dead]})))

  (utility survival)

  (effects
    (begin-proposal {@self assault ?victim})))

; The dead-twin: end the standing kill goal once V is believed dead - satisfied
; (his own kill) or moot (another's). Owns only ITS goal's conclusion.
(npc-think kill_concluded
  (cooldown 1 m)
  (goal {@self kill ?victim})
  (when (believes {?victim condition [k dead]}))
  (effects
    (end-goal {@self kill ?victim})))
