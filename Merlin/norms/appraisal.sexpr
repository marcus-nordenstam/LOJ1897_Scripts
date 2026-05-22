; ----------------------------------------------------------------------------
; appraisal.sexpr - emotion / appraisal tuning data.
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
; max-emotion-salience : hours - ceiling on a compounded emotion's decay
;                        window (a re-appraised grievance bumps salience up
;                        to this cap).
; mood-salience-gain   : agitation 0 -> emotion salience x1.0; peak agitation
;                        -> x(1 + gain). The event -> emotion -> mood ->
;                        biased-appraisal feedback loop.
(tuning
  :max-emotion-salience 336
  :mood-salience-gain   0.5)

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

; ---- trait affect ----------------------------------------------------------
; How a Big Five personality aspect modulates the salience of the emotions it
; governs. When the appraiser holds <aspect> at value t in [0,1] (mean 0.5), a
; named emotion's base salience is scaled by 1 + (t - 0.5) * gain; rows
; multiply when several name the same emotion. The aspect is read from the
; appraiser's own {@self <aspect> <f>} self-belief, so personality biases
; emotion the same way mood does (the section 5 feedback loop).
;   :amplifies <emotion-kind>...   the emotions this aspect governs
;   :gain      <fraction>          swing; t=1 -> x(1 + gain/2), t=0 -> x(1 - gain/2)
; Neuroticism (volatility, withdrawal) drives negative reactivity; Extraversion
; (enthusiasm) drives positive reactivity. The dark tetrad is deliberately
; absent - it shapes conduct and crime motive, not felt emotion intensity.
(trait-affect volatility :amplifies anger fear distress jealousy :gain 0.8)
(trait-affect withdrawal :amplifies grief fear shame guilt :gain 0.8)
(trait-affect enthusiasm :amplifies joy hope pride gratitude affection relief :gain 0.6)

; ---- category reactions ----------------------------------------------------
; One (reaction <category>) row per construal category. apply_construal looks
; up the row by the construal's label and runs it from the patient's point of
; view (when @self is the construed patient).
;
;   (mint <emotion-kind> :focus actor|patient|none :salience <hours>)
;       Mint {@self emotion <kind> <focus>}. focus actor / patient resolves
;       to the construal's subject / target; none leaves the focus blank.
;       salience is the base decay window, before the mood scaling.
;   (end-bond   <relation-label>)   ends   {@self <label> <actor>}
;   (begin-bond <relation-label>)   begins {@self <label> <actor>}
;
; Only `betray` has a category test in appraisal.cc today; adding a test
; there plus a row here is all a new category needs.
(reaction betray
  (mint anger :focus actor :salience 12)
  (mint grief :focus none  :salience 72)
  (end-bond   love)
  (begin-bond distrusts))
