; ----------------------------------------------------------------------------
; perpetration.hsc - PR-3d 2026-05-25.
;
; Method table for the generative-perpetration event (attempt_harm.hse).
; One row per method (33 total: 26 kill methods + 7 non-kill). At fire
; time, run_generative_perpetration walks the actor's standing goal
; beliefs cross-product these rows, filters by /goal-fit + /requires +
; (future /victim-state / /in-season), weighted-samples by
; base * disinhibition * pressure-floor, and dispatches the chosen
; row's /terminal.
;
; Row schema:
;   (method <atom>
;     /goal-fit       <goal-label>...           ; which goals this method satisfies
;     /requires       (<predicate>...)          ; viability gates (control_any wired; others ignored in PR-3d)
;     /victim-state   <atom>                    ; parsed-but-not-yet-gated
;     /in-season      <atom>                    ; parsed-but-not-yet-gated
;     /yields         <evidence-atom>...        ; wound/stain/mark atoms passed to yield_evidence
;     /method-aux     <atom>                    ; rides the band-5 act-anchor's /aux slot
;     /terminal       <terminal-atom>           ; which C++ terminal verb to dispatch
;     /wound-site     <body-part-atom>          ; where wound/stain/mark land (default torso)
;     /pressure-floor <kind> <intensity>        ; weight bias when pressure held
;     /strength-demand <0..1>                   ; muscle the method needs (default 0)
;     /weight         <base>)                   ; base selection weight
;
; /strength-demand (0..1) gates physical viability against the genetic
; `strength` attr. 0 = no muscle needed - the great equalizers a frail
; poisoner or a woman with a pistol use as readily as anyone (poison /
; shoot / bomb leave it unset). Higher values mean overpowering the victim
; IS the act (strangle / beat). It scales two things: the SELECTION dampener
; (a weaker-than-victim attacker is less likely to pick the method) and the
; dispatch-time ATTEMPTED-MURDER roll (if they pick it anyway, a strength
; deficit can make them FAIL - the victim survives, injured, and knows the
; attacker). This is how poison becomes the weak attacker's rational choice.
;
; PR-3d v1 wires /requires (control_any <kind>) only. Other /requires
; predicates (access_any, has_authority_over, trait gates) are
; documentation - rows fire even when those predicates would fail. A
; follow-up extends the evaluator.
;
; Body-part inventory today: head / left_hand / right_hand / finger /
; eye / mouth / torso. Methods that conceptually target neck/lungs/
; limbs map to nearest existing part (head for neck wounds; torso for
; chest/abdomen/lungs; hand for grip/extremity).
; ----------------------------------------------------------------------------

; ============================================================================
; KILL family (26 methods)
; ============================================================================

; ---- Sharp (3) -------------------------------------------------------------
(method stab
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets pierce)))
  /yields         puncture_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  ; A blade is an equalizer - less muscle than a grapple, but overpowering a
  ; struggling victim to land the thrust still takes some strength.
  /strength-demand 0.35
  /weight         1.0)

(method slash
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets slash)))
  /yields         slash_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /strength-demand 0.4
  /weight         0.7)

(method decapitate
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets chop)))
  /victim-state   defenseless
  /yields         slash_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  /pressure-floor humiliation 0.8
  /strength-demand 0.8
  /weight         0.3)

; ---- Blunt (3) -------------------------------------------------------------
(method beat_to_death
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets bludgeon)))
  /yields         blunt_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; Brute force - sustained blows on a resisting victim, the whole act is
  ; overpowering them. The clearest strength-gated method.
  /strength-demand 0.9
  /weight         0.8)

(method bludgeon
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets bludgeon)))
  /yields         blunt_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; A weapon multiplies force, but landing a lethal blow on a struggling
  ; adult still favours the stronger party.
  /strength-demand 0.7
  /weight         0.9)

(method push_from_height
  /goal-fit       kill
  /yields         blunt_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  ; A shove off a height needs less raw power than a grapple, but a
  ; stronger victim resists the edge or pulls the pusher with them.
  /strength-demand 0.55
  /weight         0.4)

; ---- Asphyxiation (5) ------------------------------------------------------
(method strangle
  /melee
  /goal-fit       kill
  /victim-state   defenseless
  /yields         ligature_mark bruise
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; Bare-handed throttling - holding a struggling victim down until they
  ; stop. Almost pure strength contest; the classic method a weaker
  ; attacker cannot pull off against a stronger one.
  /strength-demand 0.85
  /weight         0.6)

(method garrotte
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets strangle)))
  /victim-state   defenseless
  /yields         ligature_mark
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; A ligature gives leverage over bare hands, but still a hold-them-down
  ; struggle.
  /strength-demand 0.65
  /weight         0.5)

(method smother
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets smother)))
  /victim-state   defenseless
  /yields         bruise
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; Pressing a pillow over an able-bodied adult is a hold-down; trivial on
  ; an infant or the infirm (the defenseless gate the roll also reads).
  /strength-demand 0.6
  /weight         0.4)

(method hang
  /melee
  /goal-fit       kill
  /requires       ((control_any (facets strangle)))
  /victim-state   defenseless
  /yields         ligature_mark
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; Stringing up a live, resisting victim is a heavy physical job.
  /strength-demand 0.7
  /weight         0.3)

(method neck_snap
  /melee
  /goal-fit       kill
  /victim-state   defenseless
  /yields         bruise
  /method-aux     _
  /terminal       kill_victim
  /wound-site     head
  ; Breaking a neck by hand is the most strength- and skill-dependent
  ; unarmed kill there is.
  /strength-demand 0.9
  /weight         0.2)

; ---- Projectile (1) --------------------------------------------------------
(method shoot
  /melee
  /goal-fit       kill
  /requires       ((control_any firearm))
  /yields         puncture_wound
  /method-aux     firearm
  /terminal       kill_victim
  /wound-site     torso
  /weight         1.0)

; ---- Explosive (1) ---------------------------------------------------------
(method bomb
  /goal-fit       kill
  /requires       ((control_any explosive))
  /yields         burn_wound blunt_wound
  /method-aux     explosive
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.2)

; ---- Chemical (1) ---------------------------------------------------------
; poison: the chronic / acute administering kill task (Tasks.mon `poison`).
; Gated on CONTROL of a `toxin` fluid (Objects.mon fluid > toxin - a
; concentrated poison with a fill level): owned / authorized / purchase /
; steal via weapon_acquire. Deliberately NOT profession-gated - arsenic was
; over-the-counter (a public-space buy rides the purchase trail: receipt +
; sales_record, the poison register); medical staff get authorized
; hospital-dispensary access with NO trail (0.9x vs purchase 0.7x) -
; cleaner access, exactly Cream. No /yields - poison leaves no mechanical
; residue; each dose laces the victim's drink (the drink fluid's `taint`
; attr) and depletes the bottle, the staging composition adds the restraint
; hand bruise (the detective's contradiction), and the burial verdict reads
; the corpse as natural either way.
; Chronic dosing (serial_predation 4d): poison_administer doses monthly
; (act anchor + administering marker + the victim's circle learning
; {victim health_situation ailing} - priming the natural-death prior);
; the standing kill goal persists until the cumulative dose is lethal,
; then the shared kill path runs. The victim dies weeks after last
; contact with the killer - the delayed covert death.
(method poison
  /goal-fit       kill
  /requires       ((control_any toxin))
  /method-aux     _
  /terminal       poison_administer
  /wound-site     torso
  ; Poison was a prominent Victorian murder method, not a fringe one -
  ; cheap, covert (passes as natural death), and needing no strength, so it
  ; is the rational choice for the weak / female poisoner the strength gate
  ; steers here. The base only sets how often a course STARTS (competitive
  ; with the physical methods); the stowed-poison commitment multiplier in
  ; perpetration.cc carries a started course through its multi-month doses,
  ; so the base need not be inflated to overcome the re-roll fragility. (The
  ; tiny no-args repro regenerates a different town per parameter, so the
  ; absolute poison count there is noisy - tune the rate on the full
  ; population, not single repro runs.)
  /weight         1.5)

; ---- Fixation axes (serial_predation generalized victim-type) --------------
; The trait axes a serial predator can fixate on. A predator's profile is
; seeded by copying 1-2 of these axes' values off a random "type prototype"
; person; the victim scan then HARD-filters candidates to those matching the
; full profile. Each axis is read generically (attr / derived belief / job
; kind), so adding an axis here needs no C++ - only that the trait exists on
; humans. Order is irrelevant; the seeder samples uniformly.
(fixation-axis gender)
(fixation-axis height)
(fixation-axis girth)
(fixation-axis appearance)
(fixation-axis hair_color)
(fixation-axis eye_color)
(fixation-axis nationality)
(fixation-axis class_situation)
(fixation-axis job)

; ---- Skill-affinity map (serial_predation 4c / 4f(i)) ----------------------
; An actor skilled_in <domain> picks the mapped methods more readily
; (x k_skill_affinity_mult at the weight site), and committing a mapped
; method mints the `practice` marker for its FIRST declared domain -
; the loop that turns a poisoner into a craftsman. Domains are `domain`
; sub-kinds (Concepts.mon); methods are (method ...) atoms above.
(skill-affinity poisoning_knowledge (methods poison))
(skill-affinity medicine            (methods poison))
(skill-affinity marksmanship        (methods shoot))
(skill-affinity knife_fighting      (methods stab slash))
; Contract-killing pool skills (the hired-killer types steer to their craft).
; pugilism / wrestling = the prizefighter / bully (beat the victim down);
; garrotting = the footpad's silent strangle-and-cosh (the 1862 panic).
(skill-affinity pugilism            (methods beat_to_death strangle))
(skill-affinity wrestling           (methods strangle beat_to_death))
(skill-affinity garrotting          (methods garrotte strangle bludgeon))

; ---- Hydraulic (1) --------------------------------------------------------
; (access_any body_of_water) re-lands when the kind + env water features
; exist; access_any IS evaluated now, and an unresolvable kind would just
; warn-and-drop at load (leaving the row ungated either way).
(method drown
  /goal-fit       kill
  /victim-state   defenseless
  /yields         bruise
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  ; Holding a struggling victim under water is a sustained strength
  ; contest, even though the staged corpse reads as an accident.
  /strength-demand 0.7
  /weight         0.3)

; ---- Thermal (4) ----------------------------------------------------------
(method freeze
  /goal-fit       kill
  /victim-state   defenseless
  /in-season      winter
  /yields         burn_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.2)

(method immolate
  /goal-fit       kill
  /requires       ((control_any (facets burn_fuel)) (control_any (facets ignite)))
  /yields         burn_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.3)

(method arson
  /goal-fit       kill
  /requires       ((control_any (facets burn_fuel)) (control_any (facets ignite)))
  /yields         burn_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.4)

; (access_any hot_enclosure) re-lands with the kind (see drown note).
(method cook_alive
  /goal-fit       kill
  /victim-state   defenseless
  /yields         burn_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.1)

; ---- Electrical (0) - electrocute retired 2026-05-26 with the
; electrical_apparatus kind. Anachronistic for most of the 1700-1897
; window anyway (mains electrification is late 1880s+); reintroduce
; with specific kinds (electric_lamp / telegraph_apparatus) when the
; setting demands.

; ---- Animal (2) - require animal substrate that doesn't exist yet ---------
; Authored for completeness. (access_any ...) IS evaluated now (reach at
; home / workplace / public / free-standing feature), but the animal kinds
; are not declared in the ontology yet - the gates re-land with the
; animal substrate (an unresolvable kind would warn-and-drop at load,
; leaving the rows ungated either way). Weights stay tiny meanwhile.
(method unleash_animal
  /goal-fit       kill
  /yields         bite_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.05)

(method unleash_insect
  /goal-fit       kill
  /victim-state   defenseless
  /yields         bruise
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.05)

; ---- Trap (1) -------------------------------------------------------------
(method death_trap
  /goal-fit       kill
  /requires       ((control_any tools))
  /yields         blunt_wound
  /method-aux     tools
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.2)

; ---- Indirect (2) - delegation-based --------------------------------------
; arrange_accident retired 2026-05-26 - too vague to be useful (per design
; review). push_from_height IS an arranged accident; future named
; staged-accidents (poisoning, gas-leak, carriage-collision) get explicit
; rows when authored.

; uriah_gambit: dispatch to a lethal posting. Needs has_authority_over
; (not gated in PR-3d) - authored anyway with low weight.
(method uriah_gambit
  /goal-fit       kill
  /requires       ((has_authority_over))
  /yields         puncture_wound
  /method-aux     _
  /terminal       kill_victim
  /wound-site     torso
  /weight         0.1)

; commission_killing: the hired-killing CONSPIRACY (replaces the old
; hire_assassin self-kill). The instigator outsources the murder to a
; connected killer (class-gated connection + blood money, in
; contract_killing.cc). NO corpse, NO wound and NO method are decided HERE -
; the commission only strikes the contract + plants the kill goal on the
; hireling. The METHOD is entirely the hireling's: his own perpetration picks
; it from HIS skills + weapon access + forensic signature (a garrotter
; strangles, a marksman shoots, a desperate ex-soldier takes whatever he can
; get), and the instigator is provably elsewhere (the alibi). So this method
; carries no /wound-site / /yields / /method-aux - it is pure delegation. Low
; base weight: outsourcing needs money AND a connection AND a reason to
; delegate (status / physical inability), so a hired hit is rarer than a
; personal one. The terminal re-checks reachability + affordability; an
; unconnected / broke instigator simply falls back to a personal method.
(method commission_killing
  /goal-fit       kill
  /terminal       commission_killing
  /weight         0.05)

; ============================================================================
; NON-KILL family (7 methods)
; ============================================================================

; ---- steal (2) ------------------------------------------------------------
(method opportunist_theft
  /goal-fit       steal
  /method-aux     _
  /terminal       transfer_property
  /weight         1.0)

(method embezzle
  /goal-fit       steal
  /requires       ((has_authority_over))
  /method-aux     _
  /terminal       transfer_property
  /weight         0.4)

; ---- expose (2) -----------------------------------------------------------
(method confront_publicly
  /goal-fit       expose
  /method-aux     _
  /terminal       publish_secret
  /weight         0.6)

(method anonymous_letter
  /goal-fit       expose
  /requires       ((can_write))
  /method-aux     _
  /terminal       publish_secret
  /weight         0.4)

; ---- coerce (2) -----------------------------------------------------------
(method threaten_violence
  /goal-fit       coerce
  /method-aux     _
  /terminal       silence_coerce
  /weight         0.7)

(method blackmail
  /goal-fit       coerce
  /method-aux     _
  /terminal       silence_coerce
  /weight         0.5)

; ---- confess (1) ------------------------------------------------------------
; The exposure_risk confess_letter affinity gains its terminal:
; the actor reveals their
; OWN secret to their nearest kin - the secret reaches the father from
; HER. Scandal without murder; the leak also kills any standing blackmail
; leverage (the coercion refresh pass sees the secret is out).
(method confess_letter
  /goal-fit       confess_letter
  /method-aux     _
  /terminal       confess_secret
  /weight         1.0)

; ---- hurt (1) -------------------------------------------------------------
(method beating
  /goal-fit       hurt
  /yields         bruise
  /method-aux     _
  /terminal       harm_non_lethal
  /wound-site     torso
  /weight         1.0)

; ============================================================================
; PR-3d new goal-label family (5 methods, one per new goal)
; ============================================================================

; humiliate goal -> public_slight terminal (witness-propagated humiliation)
(method public_humiliation
  /goal-fit       humiliate
  /method-aux     _
  /terminal       public_slight
  /pressure-floor humiliation 0.6
  /weight         1.0)

; report_crime goal -> file_report terminal. NOT a crime - the lawful
; channel: the terminal files a crime_report letter at the police station
; (the victimhood sentence + a {victim suspect culprit} sentence when the
; grievance names its wrongdoer) and appends NO ledger row. The station is
; unstaffed by design - the letters are the PLAYER's case feed.
; (The old discredit goal / spread_rumour method is gone: reputation damage
; is emergent via witnesses + gossip, never a deliberated "start a rumour".)
(method report_to_police
  /goal-fit       report_crime
  /requires       ((can_write))
  /method-aux     _
  /terminal       file_report
  /weight         1.0)

; bribe goal -> pay_off terminal (cash transfer; PR-3d ships as mint-only stub)
(method offer_bribe
  /goal-fit       bribe
  /method-aux     _
  /terminal       pay_off
  /weight         1.0)

; frame goal -> plant_evidence terminal (yields planted on framed party)
(method plant_evidence
  /goal-fit       frame
  /yields         blood_stain
  /method-aux     _
  /terminal       plant_evidence
  /wound-site     torso
  /weight         1.0)

; seduce goal -> consummate terminal (reciprocal lover beliefs)
(method seduction
  /goal-fit       seduce
  /method-aux     _
  /terminal       consummate
  /weight         1.0)

; ============================================================================
; Item prices (shillings) - the acquisition calculus's affordability gate.
;   (item-price <kind> <price>)
; A purchase requires bank_balance >= price and debits it. Lookup is
; most-specific-first: an exact kind row wins, else the first row the
; candidate's kind is_a. Unlisted kinds use the engine default (cheap
; everyday goods - rope, hammer, bedsheet - that anyone can buy).
; Scale: bank_balance ranges roughly 0..150 (wealth = balance/120), so a
; labourer cannot afford a firearm but anyone can afford rope.
; ============================================================================
(item-price firearm        60)
(item-price explosive      40)
(item-price toxin           8)
(item-price candlestick    12)
(item-price oil_lamp        4)
(item-price axe             3)
(item-price cleaver         3)
(item-price knife           2)
(item-price hammer          2)
(item-price rope            1)

; ============================================================================
; KILL-METHOD COST MODEL (the commitment reframe). Once a month each would-be
; killer scores every NON-deferred method for a victim and COMMITS to the
; cheapest; the place lane then fires that method ONLY at its occasion (so a
; poisoner waits for a meal instead of being dragged into a night attack). All
; the numbers below are KNOBS - tune here, no recompile.
;
;   cost = w_opp*O + w_req*R + w_exec*E + w_aversion*A + w_exposure*X
;     O  opportunity - the co-presence the method's occasion needs, by relationship
;     R  requirement - getting the instrument (toxin / firearm; blades are cheap)
;     E  execution   - strength deficit (read from the method's /strength-demand)
;                      + skill miss (an unskilled shot is dear)
;     A  aversion    - personality recoil from the method's nature
;     X  exposure    - getting caught, scaled by the killer's machiavellianism
; Lowest cost wins; ties within `near-tie-band` are sampled (any will do).
; ============================================================================

(cost-weight opportunity 1.0)
(cost-weight requirement 1.0)
(cost-weight execution   1.0)
(cost-weight aversion    1.0)
(cost-weight exposure    1.0)
(cost-knob   near-tie-band   0.15)   ; fraction of the min cost counted a "tie"
(cost-knob   exec-skill-miss 0.40)   ; execution penalty for an unskilled skill-method
(cost-knob   exec-strength   1.20)   ; scales the strength deficit into execution cost
(cost-knob   req-firearm-own 0.20)   ; R when a needed item is owned / in hand
(cost-knob   req-authorized  0.20)   ; R via authorized access (medic -> dispensary toxin)
(cost-knob   req-purchase    0.60)   ; R via a (trail-leaving) purchase
(cost-knob   req-steal       0.80)   ; R via theft
(cost-knob   req-blade       0.10)   ; a knife is in every kitchen
(cost-knob   req-blunt       0.05)   ; a poker / candlestick is to hand anywhere
(cost-knob   req-unavailable 9.00)   ; cannot get the instrument -> method ruled out

; Opportunity cost: (opportunity <relationship> <occasion> <cost>). Relationships:
; cohabitant (shares the home - INCLUDING live-in household staff, so the cook /
; maid poisoning the family or a fellow servant is cheap), coworker (shares the
; workplace, incl. day staff), friend, acquaintance, stranger. Occasions: meal,
; night_home, street. A high cost means "this method's occasion is hard to reach
; for this relationship" (a stranger shares no meal; only the street is open).
(opportunity cohabitant   meal        0.10)
(opportunity cohabitant   night_home  0.10)
(opportunity cohabitant   street      0.30)
(opportunity coworker     meal        0.30)
(opportunity coworker     night_home  1.30)
(opportunity coworker     street      0.30)
(opportunity friend       meal        0.50)
(opportunity friend       night_home  1.30)
(opportunity friend       street      0.30)
(opportunity acquaintance meal        0.90)
(opportunity acquaintance night_home  1.30)
(opportunity acquaintance street      0.40)
(opportunity stranger     meal        1.60)
(opportunity stranger     night_home  1.30)
(opportunity stranger     street      0.40)

; Per-method cost class. (kill-cost <method> (occasion <occ>...) (requirement
; <none|blade|blunt|firearm|toxin>) (aversion <hands_on|ranged|covert>)
; (exposure <0..1>)). The /strength-demand is read from the (method ...) row
; above, not repeated here. A kill method with NO kill-cost row is DEFERRED -
; it is never chosen until its occasion/opportunity is modelled (the exotic
; methods: push_from_height, drown, arson, cook_alive, death_trap, freeze,
; unleash_animal, unleash_insect, hang, decapitate, neck_snap, uriah_gambit).
(kill-cost poison        (occasion meal)              (requirement toxin)   (aversion covert)   (exposure 0.10))
(kill-cost strangle      (occasion night_home)        (requirement none)    (aversion hands_on) (exposure 0.30))
(kill-cost smother       (occasion night_home)        (requirement none)    (aversion hands_on) (exposure 0.30))
(kill-cost garrotte      (occasion night_home)        (requirement blunt)   (aversion hands_on) (exposure 0.30))
(kill-cost beat_to_death (occasion night_home street) (requirement none)    (aversion hands_on) (exposure 0.40))
(kill-cost bludgeon      (occasion night_home street) (requirement blunt)   (aversion hands_on) (exposure 0.40))
(kill-cost stab          (occasion night_home street) (requirement blade)   (aversion hands_on) (exposure 0.40))
(kill-cost slash         (occasion night_home street) (requirement blade)   (aversion hands_on) (exposure 0.40))
(kill-cost shoot         (occasion street)            (requirement firearm) (aversion ranged)   (exposure 0.50))
