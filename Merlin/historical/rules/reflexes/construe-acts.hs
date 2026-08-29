; ----------------------------------------------------------------------------
; construe_acts (npc-reflex, appraise phase) - the construal doctrine.
;
; One rule per construed_act family: an act belief carrying the tag construes
; as that category with the act's own parties. Multi-tag anchors accumulate
; (an embezzle construes appropriation AND wrong AND betray - one rule each).
; The two EXCEPTIONS carry their doctrine visibly:
;   wrong_act - the value gate (permissive on a silent substrate) and, for
;     violence, RUNTIME blame: violent labels carry no static wrong_act tag;
;     a violent act is wrong unless it traces to prior violence against its
;     own actor (self-defence exoneration via the cause chain).
;   intimacy_act - betray-by-diversion: each exclusive-bond partner of the
;     actor OTHER than the act's patient is construed as betrayed.
; Replaces the appraisal.cc generator registry (categorize / generate_*).
; ----------------------------------------------------------------------------

(npc-reflex {?agent (construed-labels harm_act) ?patient /ever}:?b
  (effects (construe ?b harm_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels appropriation_act) ?patient /ever}:?b
  (effects (construe ?b appropriation_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels suffer_loss_act) ?patient /ever}:?b
  (effects (construe ?b suffer_loss_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels coercion_act) ?patient /ever}:?b
  (effects (construe ?b coercion_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels threaten_act) ?patient /ever}:?b
  (effects (construe ?b threaten_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels slight_act) ?patient /ever}:?b
  (effects (construe ?b slight_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels rivalrous_act) ?patient /ever}:?b
  (effects (construe ?b rivalrous_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels betray_act) ?patient /ever}:?b
  (effects (construe ?b betray_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels degrade_act) ?patient /ever}:?b
  (effects (construe ?b degrade_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels expose_act) ?patient /ever}:?b
  (effects (construe ?b expose_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels abandonment_act) ?patient /ever}:?b
  (effects (construe ?b abandonment_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels honour_act) ?patient /ever}:?b
  (effects (construe ?b honour_act ?agent ?patient)))

; (No construe rules for help_act / aid_act / provision_act / commitment_act /
; repudiation_act: NO hsim label carries those tags today - a (construed-labels
; <tag>) gate over an empty family is a load error, deliberately. Their REACT
; rows in reactions.hs stay authored: the moment an act declares the tag, the
; construe rule here is one line and the reactions are ready.)

; -- wrong_act, static wrongs (steal / defraud / embezzle / kidnap / expose /
; disinherit / coerce / humiliate / frame ...). Value gate: permissive when the
; act declares no (contradicts ..) or the patient's value substrate is silent;
; strict when the substrate speaks and says no.
(npc-reflex {?agent (construed-labels wrong_act) ?patient /ever}:?b
  (decl-of ?b contradicts):?v
  (when (or (not (substantial ?v))
            (not {?patient value ?})
            {?patient value ?v}))
  (effects (construe ?b wrong_act ?agent ?patient)))

; -- wrong_act, violence (runtime blame - the fight-lane doctrine). Violent
; labels carry NO static wrong_act tag; blame is earned here unless the blow
; traces to prior violence against its own actor.
(npc-reflex {?attacker (theme-labels violent_to) ?victim /ever}:?belief
  (when (not (has-cause ?belief {? (theme-labels violent_to) ?attacker})))
  (decl-of ?belief contradicts):?v
  (when (or (not (substantial ?v))
            (not {?victim value ?})
            {?victim value ?v}))
  (effects (construe ?belief wrong_act ?attacker ?victim)))

; -- intimacy_act: the standard construal PLUS betray-by-diversion - each
; exclusive-bond partner of the actor other than the act's patient is a
; betrayed party (the appraiser construes on their behalf; for the betrayed
; holder themselves ?victim binds @self and the patient-POV reactions fire).
(npc-reflex {?agent (construed-labels intimacy_act) ?patient /ever}:?b
  (effects (construe ?b intimacy_act ?agent ?patient)))

(npc-reflex {?agent (construed-labels intimacy_act) ?patient /ever}:?b
  (role ?victim {?agent (exclusive-bond-labels) ?victim}
        (not (eq ?victim ?patient)))
  (effects (construe ?b betray_act ?agent ?victim)))
