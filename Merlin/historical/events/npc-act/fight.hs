; ----------------------------------------------------------------------------
; fight - the EMERGENT confrontation (unified think/act model, future_work.md).
;
; There is NO confrontation subsystem. A violent killing is just the killer
; running the normal think -> act -> complete -> re-deliberate loop with SHORT
; (1-minute) attack acts: each blow is `(strike-blow)` (resolve_attack: hit/wound
; by weapon class, skill, strength, intent), the "rounds" are the completion-heap
; stepping the 1-minute acts, and the kill ENDS the fight (a fatal blow runs
; propagate_death, so the co-presence gate then fails and the strikes stop).
;
; THIS FIRST CUT covers the AGGRESSOR's side: an armed killer who holds a kill
; goal and is co-present with the victim falls upon them and strikes until a fatal
; blow lands. (Holding a [k weapon] gates OUT the non-violent methods - a poisoner
; carries toxin, not a weapon, so they never enter this melee.) Still to come:
; the victim's threat-perception + fight-back, flee / yield short-term-think, and
; routing the perpetration method-choice here instead of run_generative_perpetration.
; ----------------------------------------------------------------------------

; The `fight` goal is minted by the perpetration MELEE branch (a violent murder
; method leaves it standing instead of committing the kill). The killer uses
; whatever weapon they hold (means_cascade arms a stab/shoot/bludgeon method) or
; their bare hands (strangle / beat) - so this fires for ALL melee methods, armed
; or not. The intent is kill (the goal descends from a kill goal).

; APPROACH: a killer not yet with the victim seeks them out - stalk to the
; victim's HOME (where they return at night). When the victim is co-present there,
; kill_strike (utility 200) outweighs this seek (150) and the blows begin. This is
; the minimal `reach` leg; a general location-of/stalk refinement is future work.
(hsim-event kill_seek
  (intra-day)
  (nl   "@self stalks their victim")
  (when (and (has-goal fight)
             (not (co-present @self (goal-focus fight)))))
  (utility 150)
  (effects (go @self (home-of (goal-focus fight)))))

; The killer at the victim strikes - a committed murderer prioritises the blow
; over everything (utility 200 dominates work 80 / sleep 100). A 1-minute act;
; its completion lands the blow and the stepper re-deliberates the killer.
(hsim-event kill_strike
  (intra-day)
  (nl   "@self falls upon their victim")
  (when (and (has-goal fight)
             (co-present @self (goal-focus fight))))
  (utility 200)
  (effects (act kill_blow 1)))

; The blow (chain-only completion): one exchange of the emergent fight. A fatal
; result runs the ledger + propagate_death inside (strike-blow); a non-fatal one
; leaves a wound and the next deliberation strikes again (while the victim lives
; and is still co-present).
(hsim-event kill_blow
  (schedule (chain-only))
  (nl   "@self strikes a violent blow")
  (effects
    ; (strike-blow <foe> <intent>) - the actor is implicit (@self); pass the foe +
    ; intent atom only.
    (strike-blow (goal-focus fight) kill)
    (log _kill_blow @self)))
