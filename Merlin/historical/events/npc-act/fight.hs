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
; THE AGGRESSOR's side: an armed killer who holds a kill goal and is co-present
; with the victim falls upon them and strikes until a fatal blow lands. (Holding a
; [k weapon] gates OUT the non-violent methods - a poisoner carries toxin, not a
; weapon, so they never enter this melee.)
;
; THE VICTIM's side (fight_back, below): when a blow lands non-fatally, the
; strike-blow primitive mints {@self under_attack <foe>} on the victim and WAKES
; it (re-deliberate this very minute, interrupting sleep / work). The victim's
; (short-term-think) then decides - by combat resolve - to turn and fight, minting
; its OWN {@self goal {@self fight <foe>}}: the SAME kill_seek / kill_strike /
; kill_blow now fire for it too, so the fight is TWO-SIDED and trades blows until
; one party dies. Still to come: flee / yield short-term-think (a victim who will
; not fight currently just endures), and routing the perpetration method-choice
; here instead of run_generative_perpetration.
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

; THE VICTIM FIGHTS BACK (intra-day act). A struck victim holds the threat state
; {@self under_attack <foe>} (set in the victim's mind by the blow that landed) and
; was woken THIS instant. If the foe is still co-present and the victim's combat
; resolve (volatility + sadism + low compassion - the run_confrontation formula)
; carries it THIS round, it lands a blow of its own: the two-sided exchange.
;
; NO standing fight goal for the victim: the persistent under_attack state plus a
; PER-ROUND resolve roll drive each defensive blow, so a wavering victim trades
; some rounds and falters others, versus the committed aggressor who always strikes
; via its fight goal. (Folding the decision into the act gate, not a separate think,
; keeps the whole victim reaction READ-ONLY in the deliberation cascade - a real
; goal-write mid-cascade is unsafe; only the serial completion pass writes beliefs.)
; Gated on the foe being PRESENT (no swinging at a fled / slain attacker) and on
; not already holding a fight goal (then kill_strike covers it). Flee / yield is a
; follow-up; a victim who never wins the roll simply endures.
(hsim-event defend_strike
  (intra-day)
  (nl   "@self fights back")
  (when (and (under-attack)
             (not (has-goal fight))
             (co-present @self (threat-focus))
             (chance (clamp (+ (attr @self volatility)
                               (attr @self sadism)
                               (- 1.0 (attr @self compassion)))
                            0.05 0.95))))
  (utility 200)
  (effects (act defend_blow 1)))

; The victim's blow (chain-only completion), mirroring kill_blow but striking the
; THREAT focus (the attacker) rather than a fight-goal focus. A fatal result runs
; the ledger + propagate_death inside (strike-blow) and clears the dead foe's hold;
; a non-fatal one re-arms the attacker's own under_attack (the exchange continues).
(hsim-event defend_blow
  (schedule (chain-only))
  (nl   "@self strikes back")
  (effects
    (strike-blow (threat-focus) kill)
    (log _defend_blow @self)))
