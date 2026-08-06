; ----------------------------------------------------------------------------
; deliberation.hsc - Phase 10 Phase D Pivot A (2026-05-24).
;
; The affinity table for the generative-deliberation event (deliberate.hse).
; One row per (pressure-kind, action) pair plus always-included floor rows.
;
; Format:
;   (affinity <pressure-kind-atom> <action-atom> <weight-number>)
;     The cast actor's standing pressure of <pressure-kind> contributes a
;     branch toward <action> with this base weight, multiplied by the
;     pressure intensity and the disinhibition factor (1 - inhibition/100).
;
;   (floor <action-atom> <weight-number>)
;     Always-included branch with this absolute weight, regardless of any
;     standing pressure. Keeps the modal NPC with little pressure load
;     anchored to forgive / do_nothing.
;
; Action atoms are free-form - the engine logs `deliberate: <actor> ->
; <action>` to the narrative. A follow-up PR wires action atoms to nested
; goal-belief minting (`{actor goal {actor <action> <focus>}}`).
;
; Pressure kinds must match the (pressure) block of Concepts.mon.
; ----------------------------------------------------------------------------

; NOTE: the `discredit` goal (spread_rumour) is GONE. Reputation damage is
; emergent - witnesses, leaky confidants and the gossip cascade tarnish a
; wrongdoer's repute on their own; a deliberated "start a rumour" branch
; modelled nothing real. The specific channels replace it: confide / kin
; mobilisation, expose (with actual material), humiliate (a public slight),
; and report_crime (the lawful channel - see the report_crime rows).

; ---- humiliation: a directed slight needing release ------------------------
(affinity humiliation         confront_privately   0.5)
(affinity humiliation         expose               0.4)
(affinity humiliation         withdraw             0.3)
(affinity humiliation         kill                 0.02)
(affinity humiliation         humiliate            0.5)
; Coercion + suicide tails (see the attachment_loss rows).
(affinity humiliation         coerce               0.10)
(affinity humiliation         suicide              0.01)

; ---- injustice: morally indignant; broad release set -----------------------
(affinity injustice           confront_privately   0.5)
(affinity injustice           expose               0.5)
(affinity injustice           plead                0.3)
(affinity injustice           kill                 0.02)
; The lawful channel: report the wrong to the police station. The terminal
; verifies a concrete act-grievance survives on the cause chain and files
; the crime_report letter (with a suspect sentence when the wrongdoer is
; known) for the PLAYER to read - hsim itself never adjudicates.
(affinity injustice           report_crime         0.5)

; ---- exposure_risk: standing secret may break --------------------------------
(affinity exposure_risk       silence_witness      0.4)
(affinity exposure_risk       flee                 0.4)
(affinity exposure_risk       expose_first         0.3)
(affinity exposure_risk       confess_letter       0.2)
(affinity exposure_risk       bribe                0.4)
; Cover-up / murder-to-silence: kill the witness (the exposure_risk focus is the
; patient who could expose the actor - they need not have wronged the actor).
; A tail weight so it stays rare; Part A pins the exposure_risk pressure as the
; goal's /caused_by, so the rap-sheet reads "kill <witness> <- exposure_risk".
(affinity exposure_risk       kill                 0.05)

; ---- attachment_loss: loss of a bonded other ---------------------------------
(affinity attachment_loss     mourn                0.7)
(affinity attachment_loss     withdraw             0.5)
(affinity attachment_loss     replace              0.2)
(affinity attachment_loss     seduce               0.2)   ; rebound
; The rare-but-load-bearing jealous-spouse path:
; betrayed lovers do sometimes escalate to the kill goal; the affinity
; weight is intentionally low so it stays a tail outcome, not a default.
(affinity attachment_loss     kill                 0.03)
; The jilted lover's coercion
; branch ("marry me or I show your letters to your father"). The demand
; is derived at the silence_coerce terminal from the lost relationship.
; Kill affinities stay untouched: blackmail must out-compete murder for
; the jilted party (the jilted party is L'Angelier, not the killer).
(affinity attachment_loss     coerce               0.20)
; The self-destruction tail. The engine gates this branch HARD
; (despair mood x low-resilience traits) before anything fires; the
; weight only makes it reachable. A deliberated-but-not-chosen pick
; mints the witnessed suicidal-ideation belief (the valet testimony).
(affinity attachment_loss     suicide              0.03)

; ---- moral_violation: actor's own held norms breached ------------------------
(affinity moral_violation     confess_letter       0.5)
(affinity moral_violation     confess_in_person    0.3)
(affinity moral_violation     surrender            0.2)
(affinity moral_violation     atone                0.4)
(affinity moral_violation     frame                0.2)   ; deflection

; ---- existential_threat: directed lethal danger ------------------------------
(affinity existential_threat  flee                 0.8)
(affinity existential_threat  plead                0.4)
(affinity existential_threat  surrender            0.3)
; existential_threat is the most-minted pressure (assault ->
; existential_threat is strong), so its kill affinity is held at
; 0.02, parity with humiliation / injustice / rivalry, so no single pressure
; dominates the kill-motive mix. Fear still resolves overwhelmingly to flee (0.8).
(affinity existential_threat  kill                 0.02)

; ---- status_loss: prestige drop --------------------------------------------
(affinity status_loss         withdraw             0.4)
(affinity status_loss         confront_privately   0.3)
(affinity status_loss         flee                 0.2)
; PR-A-6 2026-05-28 - structural-pressure consumers (PR-A-4 mints
; status_loss from parental + class-interloper / replacement-threat
; triangulations).
(affinity status_loss         expose               0.4)
(affinity status_loss         kill                 0.03)

; ---- autonomy_loss: capability constrained by another ----------------------
(affinity autonomy_loss       flee                 0.5)
(affinity autonomy_loss       confront_privately   0.4)
(affinity autonomy_loss       plead                0.3)

; ---- resource_scarcity: material lack --------------------------------------
(affinity resource_scarcity   plead                0.5)
(affinity resource_scarcity   steal                0.3)
(affinity resource_scarcity   withdraw             0.3)
; A theft discovered by absence (stolen_from) mints resource_scarcity with
; NO culprit focus; the engine resolves the report goal's target to the
; wronged PROP off the pressure's act cause, and the terminal drops the
; report when the scarcity has no concrete act-grievance behind it (mere
; poverty is not a crime to report).
(affinity resource_scarcity   report_crime         0.3)

; ---- obligation_strain: too many duties --------------------------------------
(affinity obligation_strain   withdraw             0.5)
(affinity obligation_strain   atone                0.3)
(affinity obligation_strain   flee                 0.2)

; ---- rivalry_pressure: directed competition ----------------------------------
; Being outdone is CONCEALED, not announced (envy is the most-hidden emotion):
; no confront branch. The dominant outlet is strive (benign envy - train for
; the rematch; resolves inline in the engine, mints the practice marker the
; sporting victor roll reads, and discharges half the pressure). humiliate is
; the deliberated put-down (a real barb about the WINNER, never about the
; loss). expose stays reachable only with actual material - the engine's
; known-secret gate applies to every expose branch, this one included.
(affinity rivalry_pressure    strive               0.6)
(affinity rivalry_pressure    humiliate            0.5)
(affinity rivalry_pressure    expose               0.4)
(affinity rivalry_pressure    kill                 0.02)

; ---- floor branches: always considered, absolute weights -------------------
(floor    forgive             0.15)
(floor    do_nothing          0.40)

; ---- action categories: which bucket biases which action -------------------
; The trait / mood bias rows below key on these buckets. An unlisted action
; (steal / bribe / strive / suicide / confront_privately) biases neutrally.
(category kill              aggressive)
(category coerce            aggressive)
(category expose            aggressive)
(category threaten          aggressive)
(category humiliate         aggressive)
(category frame             aggressive)
(category hurt              aggressive)
(category seduce            aggressive)
(category silence_witness   aggressive)
(category forgive           prosocial)
(category atone             prosocial)
(category confess_in_person prosocial)
(category confess_letter    prosocial)
(category report_crime      prosocial)
(category do_nothing        prosocial)
(category withdraw          passive)
(category flee              passive)
(category mourn             passive)
(category plead             passive)
(category surrender         passive)
(category replace           passive)
(category expose_first      passive)

; DRIVE categories - the routine intra-day lanes. Not crime buckets: these key the
; personality tilt best_proposal applies to a drive act''s utility (never the
; pressure-driven deliberation branches).
(category worship devotional)
(category work    labour)

; ---- trait biases: disposition tilts a category ----------------------------
; (trait-bias <category> <dimension> self|attr <sign>): `self` reads the
; {@self <dimension>} self-belief (Big Five aspects), `attr` the env attr
; (the Dark Tetrad). Aggressive amplifies with dark traits / volatility,
; dampens with politeness / compassion; prosocial inverts; passive rides
; withdrawal against assertiveness.
(trait-bias aggressive politeness       self -1)
(trait-bias aggressive compassion       self -1)
(trait-bias aggressive volatility       self  1)
(trait-bias aggressive narcissism       attr  1)
(trait-bias aggressive machiavellianism attr  1)
(trait-bias aggressive psychopathy      attr  1)
(trait-bias aggressive sadism           attr  1)
(trait-bias prosocial  politeness       self  1)
(trait-bias prosocial  compassion       self  1)
(trait-bias prosocial  volatility       self -1)
(trait-bias prosocial  narcissism       attr -1)
(trait-bias prosocial  machiavellianism attr -1)
(trait-bias prosocial  psychopathy      attr -1)
(trait-bias prosocial  sadism           attr -1)
(trait-bias passive    assertiveness    self -1)
(trait-bias passive    withdrawal       self  1)

; DRIVE tilts (best_proposal): the devout attend more, the industrious work harder.
; The env attr is the ground-truth trait the lanes formerly multiplied in directly.
(trait-bias devotional politeness      attr  1)
(trait-bias labour     industriousness attr  1)

; ---- mood biases: the transient in-the-moment overlay -----------------------
(mood-bias aggressive stress      self  1)
(mood-bias aggressive agitation   self  1)
(mood-bias aggressive contentment self -1)
(mood-bias prosocial  stress      self -1)
(mood-bias prosocial  agitation   self -1)
(mood-bias prosocial  contentment self  1)
(mood-bias passive    stress      self  1)

; DRIVE mood overlay: the stressed shirk - stress damps the labour drive.
(mood-bias labour stress self -1)

; ---- the master crime-scalar set --------------------------------------------
; Every aggressive-category action is throttled by (crime-scale) implicitly;
; these are the crimes OUTSIDE that category (they bias neutrally but must
; still throttle).
(crime-action steal)
(crime-action bribe)

; ---- material gates ----------------------------------------------------------
; expose is reachable only with actual discreditable material (the
; known-secret gate) - a material-less expose goal never mints.
(requires-known-secret expose)

; ---- lethal concentration ----------------------------------------------------
; Concentrate the rare kill tail on the lethal-disposed: the kill branch is
; multiplied by a centered exponential in mean(psychopathy, sadism) - 0.5
; reads x1.0; floor 0.25 (a saint still rarely, but can, kill), cap 1.8.
; A who-kills lever tuned so the overall murder rate barely moves.
(lethal-concentration kill 4.0 0.25 1.8 psychopathy sadism)

; ---- prize damping -----------------------------------------------------------
; Nobody murders over a hand of whist: a rivalry kill is damped by the gravity
; of the contested prize off the outdo cause - a parlour game a sliver, a
; sport a long shot, a post or person full weight.
(prize-damp rivalry_pressure kill game  0.02)
(prize-damp rivalry_pressure kill sport 0.25)