; ----------------------------------------------------------------------------
; kill_concluded (npc-think) - the kill goal's dead-twin. A standing {@self kill V} is
; EXECUTED by choose_kill_method, which proposes the chosen killing task (strangle /
; shoot / hire-assassin) blow by blow until V dies. Goal retirement is distributed (the
; central propagate-death goal-sweep is purged), so the standing kill goal ends itself
; the moment @self believes V dead - satisfied (his own fatal blow minted the dead-
; percept) or moot (another hand felled V and he learned by a real channel). Owns only
; ITS goal's conclusion.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think kill_concluded
  (cooldown 1 m)
  (goal {@self kill ?victim})
  (when (believes {?victim condition [k dead]}))
  (effects
    (end-goal {@self kill ?victim})))
