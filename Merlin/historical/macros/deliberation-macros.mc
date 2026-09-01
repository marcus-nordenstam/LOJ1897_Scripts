; ----------------------------------------------------------------------------
; deliberation_macros.hs - the deliberation OUTCOME dispatch + the two inline
; outlets (suicide / strive), composed from atomic ops. deliberate.hs picks a
; (pressure, action) winner via (select-joint ...); this turns that winner into
; its effect. Most actions mint a goal; suicide + strive resolve inline (they are
; not goals); a KILL whose wrongdoer is unreachable displaces onto a weaker innocent.
; ----------------------------------------------------------------------------

; despair = stress x (1 - contentment) - the self-belief reading behind the suicide gate.
(define-macro despair (?who)
  (* (any {?who stress}).target (- 1 (any {?who contentment}).target)))

; (pick-confidant ?who): a confidant to witness ?who's ideation - his living spouse,
; else the first friend he knows (read from ?who's OWN spouse / friend relations). The
; rare servant-only confidant is not modelled; the truly alone die unwitnessed.
(define-macro pick-confidant (?who)
  (if (alive (spouse-of ?who))
      (then (spouse-of ?who))
    (else (any {?who friend ?}).target)))

; The suicide outlet: the witnessed ideation is minted in a confidant's mind ALWAYS
; (the testimony trail); the act (death + the death-cause-suicide body-truth) only past
; the despair + withdrawal gate.
(define-macro resolve-suicide (?who)
  (do
    ; A confidant is optional (the truly alone die unwitnessed): guard inline, then
    ; the must-produce bind re-reads the same deterministic spouse/friend/valet ladder.
    (if (pick-confidant ?who)
        (then
          (pick-confidant ?who): ?conf
          (begin-belief ?conf {@self mention [k death-cause suicide]})))
    (if (and (>= (despair ?who) (suicide_despair_min))
             (>= (attr ?who withdrawal) (suicide_withdrawal_min)))
        (then (settle-death ?who)
            (set-attr ?who death-cause [k death-cause suicide])))))

; The strive outlet (benign envy): discharge half the driving rivalry pressure.
; No goal. Getting better at the contested domain is not a bespoke act here -
; competence accrues from performing that domain's real acts (the action pipeline
; tracks per-act skill), so the strive just bleeds the rivalry.
(define-macro resolve-strive (?who ?pressure)
  (discharge-pressure ?pressure 0.5))

; (is-migrated-crime ?action): the deliberation actions that have been re-homed as
; self-gated npc-tasks (proposed + globally competed) instead of fait-accompli goal
; terminals. GROWS one atom at a time as each crime migrates (perpetration_task_action_
; migration_plan P2/P3); an action still on the goal/terminal path must NOT appear here.
(define-macro is-migrated-crime (?action)
  (or (= ?action confess-letter)
      (= ?action report-crime)
      (= ?action coerce)
      (= ?action expose)
      (= ?action humiliate)
      (= ?action frame)
      (= ?action bribe)
      (= ?action seduce)
      (= ?action hurt)))

; Turn the deliberation winner into its effect. suicide / strive resolve inline; a MIGRATED
; crime is PROPOSED as its self-gated task (it then competes globally on the want tier,
; gated by (> (crime-scale) 0));
; every other action still mints its goal with the driving pressure pinned as /caused_by. A
; reactive KILL whose wrongdoer-focus is unreachable is displaced onto a weaker innocent by the
; separate displace_kill rule (a role-cast + roulette over the actor's orbit) - it reacts to
; this freshly-minted pressure-caused kill goal and re-routes it to a beating.
(define-macro resolve-deliberation (?action ?focus ?pressure)
  (if (= ?action suicide) (then (resolve-suicide @self))
  (else (if (= ?action strive)  (then (resolve-strive @self ?pressure))
  (else (if (is-migrated-crime ?action)
      ; begin-proposal (not maintain): deliberate fires monthly inside a weighted (branches)
      ; roulette, so a maintainer would flicker (next roll drops its support mid-flight). The
      ; latched begin-proposal survives, dedups (matching_proposal), and the self-gated crime
      ; task owns its own /succ|/fail conclusion (the twin outcome).
      (then (begin-proposal {@self ?action ?focus} /caused_by ?pressure))
      (else (begin-goal {@self ?action ?focus} /caused_by ?pressure))))))))

; (has-pressure ?actor): does ?actor hold ANY ongoing pressure belief? Folds the
; old C++ (has-pressure) op - its body was a first-ongoing {?actor pressure ?}
; bucket walk (has_any_ongoing_pressure), i.e. exactly this pattern existence.
(define-macro has-pressure (?actor)
  (prob {?actor pressure ?}))
