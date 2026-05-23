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
; One (reaction <category> :pov <pov>) row per (construal category, appraiser
; POV) pair. apply_construal looks up the row by the construal's label AND
; the appraiser's role - the SAME category fires different rows depending on
; whether @self is the patient, the actor, or a third-party observer.
;
;   :pov patient       (default if omitted) - @self is the construed patient.
;                      Anger / distress / shame patterns.
;   :pov actor         @self is the construed perpetrator. Guilt / fear /
;                      moral_violation pressure patterns; post-crime psychology
;                      lives here (plan section 10.3-AFFECT item C).
;   :pov third_party   @self is neither - a witness or member of the patient's
;                      social circle who holds the anchor (via gossip or
;                      direct perception). Softer-salience patient-like
;                      reactions; the engine half of "the village forms a
;                      view".
;
;   (mint <emotion-kind> :focus actor|patient|self|none :salience <hours>)
;       Mint {@self emotion <kind> <focus>}. focus actor / patient resolves
;       to the construal's subject / target; self resolves to the appraiser
;       themselves (useful on actor-POV rows where the actor IS @self);
;       none leaves the focus blank.
;       salience is the base decay window, before the mood scaling.
;   (end-bond   <relation-label>)   ends   {@self <label> <actor>}
;   (begin-bond <relation-label>)   begins {@self <label> <actor>}
;
; Only `betray` has a category test in appraisal.cc today; adding a test
; there plus a row here is all a new category needs. Author the actor and
; third_party POV rows as new categories with crime-perpetration consequences
; come online (plan Phase B item 8).
;
; Sadist-POV substitutions (plan section 10.3-AFFECT item K): when the
; appraiser's sadism aspect is above k_sadism_pov_threshold (0.65),
; apply_construal substitutes :pov actor_sadist for :pov actor and :pov
; third_party_sadist for :pov third_party. Falls back to the modal row if
; no sadist row is authored. patient POV is unchanged - sadism modifies the
; response to OTHERS' suffering, not one's own. The example below for
; `betray` is illustrative; once Phase B's other-nature reactions land
; (harm / wrong / threaten / ...), author sadist rows alongside the modal
; ones for each category whose anchor involves another's suffering.
(reaction betray :pov third_party_sadist
  (mint joy   :focus none  :salience 12)
  (mint pride :focus self  :salience 24))
(reaction betray
  (mint anger :focus actor :salience 12)
  (mint grief :focus none  :salience 72)
  (end-bond   love)
  (begin-bond distrusts))
