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

; The `fight` goal is minted by attempt_kill.hs (a standing kill goal routes
; here instead of committing anywhere else). The killer uses whatever weapon
; they hold (means_cascade arms, when engaged) or their bare hands (strangle /
; beat). The intent is kill (the goal descends from a kill goal).

; APPROACH: a killer not yet with the victim seeks them out - stalk to the
; victim's HOME (where they return at night). When the victim is co-present there,
; kill_strike (utility 200) outweighs this seek (150) and the blows begin. This is
; the minimal `reach` leg; a general location-of/stalk refinement is future work.
; EXPOSURE CLOCK (the killer's break-off, end-condition c). The seek/strike
; utilities hold full force for the first ~10 minutes of the episode, then DECAY
; (-30/min) as exposure mounts, while break_off_fight's utility RISES; they cross
; ~13 min, after which the killer abandons THIS attempt and leaves. (fight-elapsed)
; is wall-clock minutes since the first blow, reset each month - so the kill+fight
; goals persist but the striking is one timed burst per month.
(hsim-npc-behaviour kill_seek
  (short-term-think)
  (bind (goal-focus fight) ?victim)
  (when (and (has-goal fight)
             (bind {?victim home ?victim_home})
             (not (co-present @self ?victim))))
  (utility (if (< (fight-elapsed) 10) 150
               (max 0 (- 150 (* 30 (- (fight-elapsed) 10))))))
  (effects (go @self ?victim_home)))

; The killer at the victim strikes - a committed murderer prioritises the blow
; (utility 200 dominates work 80 / sleep 100) UNTIL the exposure clock drags it
; down. A 1-minute act; its completion lands the blow and re-deliberates the killer.
(hsim-npc-behaviour kill_strike
  (short-term-think)
  (when (and (has-goal fight)
             (co-present @self (goal-focus fight))))
  (utility (if (< (fight-elapsed) 10) 200
               (max 0 (- 200 (* 30 (- (fight-elapsed) 10))))))
  (effects (begin-act {@self fight} 1 kill_blow)))

; BREAK OFF (end-condition c): a killer whose attempt has dragged on without a kill
; gives up for now and leaves - exposure outweighs the deed. Utility is 0 for the
; first ~10 minutes then rises (+30/min), overtaking the decaying kill_strike around
; ~13 min, so the killer retreats home (breaking co-presence). The kill+fight goals
; PERSIST - cold-start clears the exposure clock and it tries again next month.
(hsim-npc-behaviour break_off_fight
  (short-term-think)
  (when (and (has-goal fight)
             (not (at-home))))
  (utility (* 30 (max 0 (- (fight-elapsed) 10))))
  (effects (go @self (target {@self home ?}))))

; The blow (completion-only completion): one exchange of the emergent fight. A fatal
; result runs the ledger + propagate_death inside (strike-blow); a non-fatal one
; leaves a wound and the next deliberation strikes again (while the victim lives
; and is still co-present).
(hsim-npc-behaviour kill_blow
  (on-completion)
  (effects
    ; (strike-blow <foe> <intent>) - the actor is implicit (@self); pass the foe +
    ; intent atom only.
    (strike-blow (goal-focus fight) kill)
    ))

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
; keeps the whole victim reaction READ-ONLY in the intra-day deliberation - a real
; goal-write mid-deliberation is unsafe; only the serial completion pass writes beliefs.)
; Gated on the foe being PRESENT (no swinging at a fled / slain attacker) and on
; not already holding a fight goal (then kill_strike covers it). A victim who does
; not win the resolve roll FLEES or SCREAMS instead (below) - never sleeps (the
; rest lane is gated out while under attack).
(hsim-npc-behaviour defend_strike
  (short-term-think)
  (when (and (under-attack)
             (not (has-goal fight))
             (co-present @self (threat-focus))
             (chance (clamp (+ (attr @self volatility)
                               (attr @self sadism)
                               (- 1.0 (attr @self compassion)))
                            0.05 0.95))))
  (utility 200)
  (effects (begin-act {@self fight} 1 defend_blow)))

; The victim's blow (completion-only completion), mirroring kill_blow but striking the
; THREAT focus (the attacker) rather than a fight-goal focus. A fatal result runs
; the ledger + propagate_death inside (strike-blow) and clears the dead foe's hold;
; a non-fatal one re-arms the attacker's own under_attack (the exchange continues).
(hsim-npc-behaviour defend_blow
  (on-completion)
  (effects
    (strike-blow (threat-focus) kill)
    ))

; THE VICTIM TRIES TO FLEE (intra-day act, end-condition b). A struck victim that
; does NOT turn to fight makes a one-round bid to break away. Lower utility than
; fighting (200), so a bold victim fights and a timid one runs. Each round is an
; ATTEMPT, not a guaranteed escape: the flee_attempt completion rolls the getaway by
; the attacker's accumulated misses + the victim's agility / strength / nerve. On
; SUCCESS the melee is OVER - the victim is whisked to a public place this instant
; (no multi-minute "fleeing" while blows keep landing) and co-presence breaks. On
; FAILURE it is still pinned and re-deliberates (fight / flee / scream) next round.
(hsim-npc-behaviour flee_attack
  (short-term-think)
  (when (and (under-attack)
             (not (has-goal fight))
             (co-present @self (threat-focus))))
  (utility 150)
  (effects (begin-act {@self flee} 1 flee_attempt)))

; The flee attempt's completion (completion-only): roll the escape. On success
; (attempt-flee) relocates the victim to safety + clears its threat state - the
; fight ends; on failure nothing changes and the victim tries again next round.
(hsim-npc-behaviour flee_attempt
  (on-completion)
  (effects
    (attempt-flee)
    ))

; THE VICTIM SCREAMS FOR HELP (intra-day act) - the last resort when it can neither
; fight (failed the resolve roll) nor flee (nowhere to run). Lowest utility, so it
; only wins when the other two produce no act. A one-minute cry that keeps the
; victim ACTIVE (never falling back to sleep / idle while under attack) and
; re-deliberating each round. (Drawing a responder who intervenes is a follow-up;
; the point here is that cowering-and-screaming, not sleeping, is the floor.)
(hsim-npc-behaviour scream_for_help
  (short-term-think)
  (when (and (under-attack)
             (co-present @self (threat-focus))))
  (utility 100)
  (effects
    (begin-act {@self scream} 1)
    ))
