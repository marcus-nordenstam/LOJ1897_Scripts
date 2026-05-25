; ----------------------------------------------------------------------------
; appraisal.hsc - emotion / appraisal tuning data.
;
; Loaded by Merlin at ontology-load time (appraisal_load_norms, called from
; t_simulator::load_ontology). Editing this file re-tunes the emotion model
; for isim AND hsim - no rebuild, no rule changes. See Docs/emotion_sim_plan.md
; sections 4.5 and 5.
;
; The category TESTS and the effect-signature table are code (appraisal.cc);
; only the tuning data - intensities, mood weights, the category -> reaction
; rows - lives here.
; ----------------------------------------------------------------------------

; ---- global tuning ---------------------------------------------------------
; max-emotion-salience  : hours - ceiling on a compounded emotion's decay
;                         window (a re-appraised grievance bumps salience up
;                         to this cap).
; max-pressure-salience : hours - ceiling on a compounded pressure's decay
;                         window. Pressures run weeks-to-years vs emotion's
;                         hours-to-days; default 8760h = 1 year (plan section
;                         10.3-AFFECT item A).
; mood-salience-gain    : agitation 0 -> emotion salience x1.0; peak agitation
;                         -> x(1 + gain). The event -> emotion -> mood ->
;                         biased-appraisal feedback loop.
(tuning
  :max-emotion-salience   336
  :max-pressure-salience  8760
  :mood-salience-gain     0.5)

; ---- emotion affect --------------------------------------------------------
; Per-emotion-kind valence and arousal. derive_mood folds the salience-
; weighted aggregate of these into the contentment / agitation dimensions.
;   valence : -1.0 (negative) .. +1.0 (positive)
;   arousal :  0.0 (calm)      ..  1.0 (activated)
; One row per kind in the Concepts.mon `emotion` taxonomy.
(emotion-affect joy       :valence  1.0 :arousal 0.6)
(emotion-affect pride     :valence  1.0 :arousal 0.5)
(emotion-affect hope      :valence  1.0 :arousal 0.4)
(emotion-affect relief    :valence  1.0 :arousal 0.2)
(emotion-affect gratitude :valence  1.0 :arousal 0.3)
(emotion-affect affection :valence  1.0 :arousal 0.3)
(emotion-affect grief     :valence -1.0 :arousal 0.2)
(emotion-affect distress  :valence -1.0 :arousal 0.7)
(emotion-affect anger     :valence -1.0 :arousal 0.9)
(emotion-affect fear      :valence -1.0 :arousal 0.9)
(emotion-affect shame     :valence -1.0 :arousal 0.4)
(emotion-affect guilt     :valence -1.0 :arousal 0.4)
(emotion-affect envy      :valence -1.0 :arousal 0.6)
(emotion-affect jealousy  :valence -1.0 :arousal 0.7)
(emotion-affect disgust   :valence -1.0 :arousal 0.5)
(emotion-affect contempt  :valence -1.0 :arousal 0.4)

; ---- pressure affect -------------------------------------------------------
; Per-pressure-kind contribution to the `stress` mood dimension (plan section
; 10.3-AFFECT item F). Higher :stress = more stress per intensity unit. A
; pressure kind without a row contributes zero stress (so authoring is
; opt-in). stress feeds the inhibition classifier (item D, lowers the
; inhibition floor) and the stress-biased categorize() threshold (item G,
; makes ambiguous events read as wrong / threaten when the appraiser is
; loaded - the paranoid-spiral / simmering-revenge feedback loop).
(pressure-affect humiliation        :stress 0.8)
(pressure-affect existential_threat :stress 1.0)
(pressure-affect exposure_risk      :stress 0.7)
(pressure-affect moral_violation    :stress 0.6)
(pressure-affect injustice          :stress 0.7)
(pressure-affect status_loss        :stress 0.6)
(pressure-affect attachment_loss    :stress 0.7)
(pressure-affect autonomy_loss      :stress 0.5)
(pressure-affect resource_scarcity  :stress 0.6)
(pressure-affect obligation_strain  :stress 0.4)
(pressure-affect rivalry_pressure   :stress 0.5)

; ---- trait affect ----------------------------------------------------------
; How a personality aspect modulates the salience of the emotion / pressure
; kinds it governs. When the appraiser holds <aspect> at value t in [0,1]
; (mean 0.5), the named kind's base salience is scaled by 1 + (deviation *
; gain), where deviation is (t - 0.5) for symmetric Big Five rows and
; max(0, t - 0.5) for one-sided Dark Tetrad rows (plan section 10.3-AFFECT
; item K). Rows multiply when several name the same kind. The aspect is
; read from the appraiser's own {@self <aspect> <f>} self-belief.
;
;   :amplifies <kind>...    kinds this aspect's deviation INCREASES
;   :dampens   <kind>...    kinds this aspect's deviation DECREASES
;                           (alias for :amplifies with negated gain)
;   :gain      <fraction>   swing strength
;   :one_sided              flag (REQUIRED for Dark Tetrad rows): the
;                           trait's effect floors at the population mean
;                           so low values contribute zero, not the
;                           symmetric inverse. Low sadism is "normal
;                           human aversion," not an anti-sadism bonus.
;
; Big Five rows (symmetric - Neuroticism / Extraversion).
(trait-affect volatility :amplifies anger fear distress jealousy :gain 0.8)
(trait-affect withdrawal :amplifies grief fear shame guilt :gain 0.8)
(trait-affect enthusiasm :amplifies joy hope pride gratitude affection relief :gain 0.6)

; Dark Tetrad rows (one-sided - low values contribute zero bias). Plan
; section 10.3-AFFECT item K: narcissism inflates threat-to-ego (humiliation
; pressure, injustice pressure, shame / anger / contempt); psychopathy
; dampens the negative-affect remorse cluster (low fear conditioning, low
; remorse capacity); machiavellianism modulates conduct via inhibition
; classifier and branch-weight composer (no emotion / pressure amplification
; - Machiavellians read accurately, they just do not care); sadism modulates
; via POV-row substitution (handled in apply_construal, not here) and
; inhibition classifier - again no trait-affect emotion bias.
(trait-affect narcissism  :amplifies humiliation injustice shame anger contempt :gain 1.2 :one_sided)
(trait-affect psychopathy :dampens   guilt fear moral_violation :gain 0.6 :one_sided)

; ---- category reactions ----------------------------------------------------
; One (reaction <construed_act-kind> :pov <pov>) row per
; (construed_act, appraiser POV) pair. apply_construal looks up the row
; by the construal-belief's label (which IS a construed_act sub-kind) AND
; the appraiser's role. The SAME kind fires different rows for patient /
; actor / third_party.
;
;   :pov patient       (default if omitted) - @self is the construal's target.
;                      Anger / distress / shame patterns.
;   :pov actor         @self is the construal's subject (the perpetrator).
;                      Guilt / fear / moral_violation pressure patterns -
;                      post-crime psychology (plan section 10.3-AFFECT item C).
;   :pov third_party   @self is neither - a witness or member of the patient's
;                      social circle who holds the anchor (via gossip or
;                      direct perception). Softer-salience patient-like
;                      reactions; the engine half of "the village forms a
;                      view".
;
; Multi-tag accumulation: an anchor declares one or more construed_act tags
; (e.g. `embezzle (construed_act appropriation_act wrong_act betray_act)`).
; categorize() emits one construal belief per tag, and each construal's
; reaction row fires independently. So an embezzle patient feels the
; appropriation_act reaction AND the wrong_act reaction AND the betray_act
; reaction - accumulated mints / pressures / bond mutations.
;
;   (mint <emotion-kind> :focus actor|patient|self|none :salience <hours>)
;       Mint {@self emotion <kind> <focus>}. focus actor / patient resolves
;       to the construal's subject / target; self resolves to the appraiser
;       themselves (useful on actor-POV rows where the actor IS @self);
;       none leaves the focus blank.
;       salience is the base decay window, before the mood scaling.
;   (pressure <pressure-kind> :focus ... :salience ...)
;       Long-burn standing motivational load (plan section 10.3-AFFECT
;       items A + B).
;   (end-bond   <relation-label>)   ends   {@self <label> <actor>}
;   (begin-bond <relation-label>)   begins {@self <label> <actor>}
;
; Sadist-POV substitutions (plan section 10.3-AFFECT item K): when the
; appraiser's sadism aspect is above k_sadism_pov_threshold (0.65),
; apply_construal substitutes :pov actor_sadist for :pov actor and :pov
; third_party_sadist for :pov third_party. Falls back to the modal row if
; no sadist row is authored. patient POV is unchanged - sadism modifies the
; response to OTHERS' suffering, not one's own.

; -- wrong_act (umbrella: any wronging - fires alongside the specific
; sub-category reactions when an anchor carries both tags) --
(reaction wrong_act :pov patient
  (mint anger    :focus actor :salience 24)
  (mint distress :focus none  :salience 72)
  (pressure humiliation :focus actor :salience 720)
  (pressure injustice   :focus actor :salience 2160)
  (end-bond   friend)
  (begin-bond enemy))

(reaction wrong_act :pov actor
  (mint guilt :focus self    :salience 720)
  (mint fear  :focus none    :salience 168)
  (pressure moral_violation :focus self    :salience 2160)
  (pressure exposure_risk   :focus patient :salience 1440))

(reaction wrong_act :pov third_party
  (mint distress :focus actor :salience 24)
  (mint fear     :focus actor :salience 48)
  (pressure injustice :focus actor :salience 1440)   ; 60 days; survives 2 monthly deliberate cycles so third-party witnesses keep their grievance long enough to act on it
  (begin-bond distrusts))

; -- harm_act (physical / mortal injury) --
(reaction harm_act :pov patient
  (mint fear :focus actor :salience 168)
  (pressure existential_threat :focus actor :salience 2160))

(reaction harm_act :pov actor
  (mint fear :focus none :salience 168))

(reaction harm_act :pov third_party
  (mint fear :focus actor :salience 48)
  (pressure existential_threat :focus actor :salience 720))

; -- appropriation_act (theft / fraud / embezzlement) --
(reaction appropriation_act :pov patient
  (mint anger :focus actor :salience 168)
  (pressure resource_scarcity :focus none :salience 1440))

(reaction appropriation_act :pov actor
  (pressure exposure_risk :focus patient :salience 1440))

(reaction appropriation_act :pov third_party
  (mint distress :focus actor :salience 24)
  (begin-bond distrusts))

; -- coercion_act (forcible compulsion) --
(reaction coercion_act :pov patient
  (mint fear :focus actor :salience 168)
  (pressure autonomy_loss      :focus actor :salience 1440)
  (pressure existential_threat :focus actor :salience 720))

(reaction coercion_act :pov actor
  (pressure moral_violation :focus self :salience 720))

(reaction coercion_act :pov third_party
  (mint fear :focus actor :salience 48))

; -- threaten_act (menace / extortion / implicit harm) --
(reaction threaten_act :pov patient
  (mint fear :focus actor :salience 72)
  (pressure existential_threat :focus actor :salience 720))

(reaction threaten_act :pov third_party
  (mint fear :focus actor :salience 24))

; -- slight_act (insult / mock / lesser affront) --
(reaction slight_act :pov patient
  (mint anger    :focus actor :salience 8)
  (mint contempt :focus actor :salience 48)
  (pressure humiliation :focus actor :salience 8760))   ; 1 year base; mood/trait scaling can only amplify (modal NPC keeps the full base), capped at max-pressure-salience.

(reaction slight_act :pov actor
  (mint pride :focus self :salience 24))

(reaction slight_act :pov third_party
  (mint contempt :focus actor :salience 24))

; -- rivalrous_act (actor positionally outcompetes patient) --
; The patient feels the loss directly; the actor's pride is folded under
; the achieve_act-style cascade if the actor's anchor is tagged that
; way (perpetration terminals may add achieve_act when relevant). Pure
; rivalrous_act mints envy + rivalry_pressure on the loser without
; minting a positive emotion on the winner; matches the social
; psychology of zero-sum competition (winner takes the prize, not the
; emotional payoff).
(reaction rivalrous_act :pov patient
  (mint envy     :focus actor :salience 168)
  (mint contempt :focus actor :salience 48)
  (pressure rivalry_pressure :focus actor :salience 4320))   ; 6 months base; rivalry decays slower than humiliation but faster than injustice

(reaction rivalrous_act :pov third_party
  (mint envy :focus actor :salience 24))

; -- betray_act (broken trust) --
(reaction betray_act :pov patient
  (mint anger :focus actor :salience 24)
  (mint grief :focus none  :salience 168)
  (pressure attachment_loss :focus actor :salience 2160)
  (end-bond   love)
  (end-bond   friend)
  (begin-bond distrusts))

(reaction betray_act :pov actor
  (mint guilt :focus self :salience 720)
  (pressure moral_violation :focus self :salience 1440)
  (pressure exposure_risk   :focus patient :salience 1440))

(reaction betray_act :pov third_party
  (mint contempt :focus actor :salience 48)
  (begin-bond distrusts))

(reaction betray_act :pov third_party_sadist
  (mint joy   :focus none :salience 12)
  (mint pride :focus self :salience 24))

; -- expose_act (public disclosure of a band-4+ secret) --
(reaction expose_act :pov patient
  (mint shame :focus none :salience 720)
  (pressure humiliation  :focus actor :salience 1440)
  (pressure status_loss  :focus none  :salience 2160))

(reaction expose_act :pov actor
  (pressure exposure_risk :focus patient :salience 720))

; -- abandonment_act (disinheritance / desertion) --
(reaction abandonment_act :pov patient
  (mint grief    :focus actor :salience 720)
  (mint distress :focus none  :salience 168)
  (pressure attachment_loss :focus actor :salience 2160)
  (pressure status_loss     :focus none  :salience 1440)
  (end-bond   friend)
  (end-bond   love))

(reaction abandonment_act :pov actor
  (mint guilt :focus self :salience 720)
  (pressure moral_violation :focus self :salience 1440))

(reaction abandonment_act :pov third_party
  (mint distress :focus actor :salience 48)
  (pressure injustice :focus actor :salience 1440))   ; 60 days; was 360 (15 days) which decayed before monthly deliberate could see it

; -- aid_act / provision_act (direct assistance / giving) --
; aid_act and provision_act share an umbrella help_act reaction. Authors
; can override per-specific category if needed.
(reaction help_act :pov patient
  (mint gratitude :focus actor :salience 168)
  (mint relief    :focus none  :salience 72)
  (begin-bond friend))

(reaction help_act :pov actor
  (mint pride :focus self :salience 72))

(reaction help_act :pov third_party
  (mint affection :focus actor :salience 48))

(reaction aid_act :pov patient
  (mint gratitude :focus actor :salience 168))

(reaction provision_act :pov patient
  (mint gratitude :focus actor :salience 168))

; -- honour_act / commitment_act --
(reaction honour_act :pov patient
  (mint pride     :focus self  :salience 168)
  (mint gratitude :focus actor :salience 168)
  (begin-bond respects))

(reaction honour_act :pov actor
  (mint pride :focus self :salience 72))

(reaction honour_act :pov third_party
  (mint affection :focus actor :salience 48))

(reaction commitment_act :pov patient
  (mint gratitude :focus actor :salience 168))

; -- intimacy_act -- (no reaction by default; betray-by-diversion is a
; structural test in categorize() that mints a betray_act construal in
; observer minds, which fires the betray_act rows above.)
