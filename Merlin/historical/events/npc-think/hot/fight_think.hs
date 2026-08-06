; ----------------------------------------------------------------------------
; fight (npc-think lane) - the EMERGENT confrontation (unified think/act model,
; future_work.md). The shared act bodies live in npc-act/fight.hs.
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
; THE VICTIM's side (defend_strike, below): when a blow lands non-fatally, the
; strike-blow primitive mints {@self under_attack <foe>} on the victim, who reacts
; at once (even mid-sleep or mid-work). The victim's under_attack rung then decides
; - by combat resolve - to turn and fight, holding its OWN {@self fight <foe>} goal:
; the SAME kill_strike / fight_act then fire for it too, so the fight is TWO-SIDED
; and trades blows until one dies.
; That fight goal is a maintenance hold ceased when the attack ends (under_attack
; drops), and the resolve is re-rolled each blow, so a wavering victim trades some
; rounds and falters others (flee / scream instead), versus the committed aggressor
; whose standing kill goal (attempt_kill.hs) never wavers.
;
; ACT MODEL: every strike / flee / scream is a goal that PROMOTES to a shared
; act body (fight_act / flee_act / scream_act) - no begin-act. The strike-vs-
; retreat choice is a UTILITY RACE between peer goals ({@self fight} vs
; {@self go home}), NOT a leaf relationship, so break_off reads the fight goal
; with (goal? ...) - which does not pin the auto-/caused_by - keeping its
; {@self go home} a standalone competitor rather than a fight sub-goal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The `fight` goal is minted by attempt_kill.hs (a standing kill goal routes here)
; for the aggressor, and per-round by defend_strike for a victim. It carries the
; foe as its focus. The killer uses whatever weapon they hold (means arms,
; when engaged) or their bare hands (strangle / beat).

; APPROACH: a killer not yet with the victim seeks them out - stalk to the
; victim's HOME (where they return at night). Pushes the fight utility (150,
; decaying with the exposure clock) onto the goal so the go sub-goal it maintains
; promotes; the fight goal is a non-leaf while {@self go ?victim_home} stands.
; When the victim is co-present there, kill_strike (utility 200) outweighs this and
; the blows begin.
; EXPOSURE CLOCK (the killer's break-off, end-condition c): the seek/strike
; utilities hold full force for the first ~10 minutes of the episode, then DECAY
; (-30/min) as exposure mounts, while break_off_fight's utility RISES; they cross
; ~13 min, after which the killer abandons THIS attempt and leaves. (fight-elapsed)
; is wall-clock minutes since the first blow, reset each month.
(npc-think kill_seek
  (goal {@self fight ?victim})

  (when (and (believes {?victim home ?victim_home})
             (not (co-present @self ?victim))))
  (utility (if (< (fight-elapsed) 10) (then 150)
               (else (max 0 (- 150 (* 30 (- (fight-elapsed) 10)))))))
  (effects
    (debug-print "TRACE_KILLSEEK @self stalks victim=?victim to ?victim_home")
    (maintain-proposal {@self enter ?victim_home})))

; The killer at the victim strikes - a committed murderer prioritises the blow
; (utility 200 dominates work 80 / sleep 100) UNTIL the exposure clock drags it
; down. Pushes the utility onto {@self fight ?victim}, which - the leaf while
; co-present - promotes to fight_act (the 1-minute blow).
(npc-think kill_strike
  (goal {@self fight ?victim})
  (when (co-present @self ?victim))
  (utility (if (< (fight-elapsed) 10) (then 200)
               (else (max 0 (- 200 (* 30 (- (fight-elapsed) 10)))))))
  (effects
    (debug-print "TRACE_KILLSTRIKE @self strikes victim=?victim")
    (begin-goal {@self fight ?victim})))

; TERMINAL step (act_body_purification): the blow itself is PROPOSED, guarded by co-presence -
; the same precondition kill_strike keys on. No (utility): the proposal inherits the fight goal's drive
; up the /caused_by chain, so the aggressor strikes at kill_strike's exposure-decayed weight (~200) and a
; struck victim who turned to fight (defend_strike) strikes at its 20000 override - ONE shared terminal,
; each actor's own drive. The exchange trades blows until one dies (a fatal blow breaks co-presence
; and the strikes stop).
(npc-think strike_foe
  (goal {@self fight ?victim})
  (when (co-present @self ?victim))
  (effects (maintain-proposal {@self fight ?victim})))

; BREAK OFF (end-condition c): a killer whose attempt has dragged on without a kill
; gives up for now and leaves - exposure outweighs the deed. Utility is 0 for the
; first ~10 minutes then rises (+30/min), overtaking the decaying kill_strike around
; ~13 min, so the retreat wins the utility race and the killer heads home (breaking
; co-presence). Reads the fight with (goal? ...) - NOT the (goal) requirement - so
; its {@self go home} stays a STANDALONE competitor of {@self fight}, not a sub-goal
; (a sub-goal would leaf-block the strike). The kill+fight goals PERSIST - cold-start
; clears the exposure clock and it tries again next month.
(npc-think break_off_fight
  (when (and (goal? {@self fight})
             (not (at-home))))
  (utility (* 30 (max 0 (- (fight-elapsed) 10))))
  ; Maintenance: mint the flee-home goal while fighting away from home; the enter chain
  ; routes there, and reaching home (or the fight ending) drops the gate -> cease.
  (effects       (bind (target {@self home ?}) ?go_dest) (maintain-proposal {@self enter ?go_dest})))

; THE VICTIM FIGHTS BACK. A struck victim holds {@self under_attack <foe>} (set by
; the blow that landed) and was woken THIS instant. If the foe is still co-present
; and the victim's combat resolve (volatility + sadism + low compassion) carries it,
; it holds {@self fight <foe>} - and kill_strike / fight_act above then drive its blow,
; the two-sided exchange. A maintenance goal: the resolve roll is re-rolled each blow
; and the fight goal ceases when the attack ends, so it re-decides each round; a lost
; roll leaves no fight goal and flee / scream take over.
(npc-think defend_strike
  (bind (threat-focus) ?foe)
  (when (chance (clamp (+ (attr @self volatility)
                          (attr @self sadism)
                          (- 1.0 (attr @self compassion)))
                          0.05 0.95)))
  (utility 20000)
  (effects       (begin-goal {@self fight ?foe}))
  (cease-effects (end-goal   {@self fight ?foe})))

; THE VICTIM TRIES TO FLEE (end-condition b). A struck victim that does NOT turn to
; fight makes a one-round bid to break away. Lower utility than fighting (200), so a
; bold victim fights and a timid one runs. The flee_attempt completion rolls the
; getaway by the attacker's misses + the victim's agility / strength / nerve. On
; SUCCESS the melee is OVER - the victim is whisked to a public place this instant
; and co-presence breaks; on FAILURE it is still pinned and re-deliberates next round.
(npc-think flee_attack
  (role ?foe (believes {@self under_attack ?foe}))
  (when (no-goal {@self fight}))
  (utility 15000)
  (effects       (begin-goal {@self flee ?foe}))
  (cease-effects (end-goal   {@self flee ?foe})))

; TERMINAL step (act_body_purification): the getaway bid is PROPOSED while the flee goal stands and
; the victim is still under attack by ?foe (flee_attack's own gate). Utility 15000 sits below a fight
; goal (20000) and above a scream (12000), so a bold victim fights and a timid one runs. The bid holds
; until the flee succeeds (whisked to a public place, co-presence breaks) or the attack ends.
(npc-think flee_foe
  (goal {@self flee ?foe})
  (when (believes {@self under_attack ?foe}))
  (utility 15000)
  (effects (maintain-proposal {@self flee ?foe})))

; THE VICTIM SCREAMS FOR HELP - the last resort when it can neither fight (failed the
; resolve roll) nor flee (nowhere to run). Lowest utility, so it only wins when the
; other two produce no act. A one-minute cry that keeps the victim ACTIVE (never
; falling back to sleep / idle while under attack) and re-deliberating each round.
(npc-think scream_for_help
  (role ?foe (believes {@self under_attack ?foe}))
  (utility 12000)
  (effects       (begin-goal {@self cry_out}))
  (cease-effects (end-goal   {@self cry_out})))

; TERMINAL step (act_body_purification): the scream is PROPOSED while the cry_out goal stands and the
; victim is under attack (scream_for_help's own gate). Utility 12000 is the lowest of the three, so it
; only wins when neither fight nor flee produced an act. It keeps the
; victim active (never lapsing to sleep / idle) while under attack.
(npc-think cry_out_alarm
  (goal {@self cry_out})
  (role ?foe (believes {@self under_attack ?foe}))
  (utility 12000)
  (effects (maintain-proposal {@self cry_out})))
