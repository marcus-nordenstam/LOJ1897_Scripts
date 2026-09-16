; ----------------------------------------------------------------------------
; construe_acts (npc-reflex, appraise phase) - the construal doctrine.
;
; One rule per construed-act family: an act belief carrying the tag construes
; as that category with the act's own parties. Multi-tag anchors accumulate
; (an embezzle construes appropriation AND wrong AND betray - one rule each).
; The two EXCEPTIONS carry their doctrine visibly:
;   wrong-act - the value gate (permissive on a silent substrate) and, for
;     violence, RUNTIME blame: violent labels carry no static wrong-act tag;
;     a violent act is wrong unless it traces to prior violence against its
;     own actor (self-defence exoneration via the cause chain).
;   intimacy-act - betray-by-diversion: each exclusive-bond partner of the
;     actor OTHER than the act's patient is construed as betrayed.
; Replaces the appraisal.cc generator registry (categorize / generate_*).
; ----------------------------------------------------------------------------

(npc-reflex {?agent (construed-labels harm-act) ?patient /ever}:?b
  (effects (construe ?b harm-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels appropriation-act) ?patient /ever}:?b
  (effects (construe ?b appropriation-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels suffer-loss-act) ?patient /ever}:?b
  (effects (construe ?b suffer-loss-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels coercion-act) ?patient /ever}:?b
  (effects (construe ?b coercion-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels threaten-act) ?patient /ever}:?b
  (effects (construe ?b threaten-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels slight-act) ?patient /ever}:?b
  (effects (construe ?b slight-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels rivalrous-act) ?patient /ever}:?b
  (effects (construe ?b rivalrous-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels betray-act) ?patient /ever}:?b
  (effects (construe ?b betray-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels degrade-act) ?patient /ever}:?b
  (effects (construe ?b degrade-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels expose-act) ?patient /ever}:?b
  (effects (construe ?b expose-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels abandonment-act) ?patient /ever}:?b
  (effects (construe ?b abandonment-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels honour-act) ?patient /ever}:?b
  (effects (construe ?b honour-act ?agent ?patient)))

; (No construe rules for help-act / aid-act / provision-act / commitment-act /
; repudiation-act: NO hsim label carries those tags today - a (construed-labels
; <tag>) gate over an empty family is a load error, deliberately. Their REACT
; rows in reactions.hs stay authored: the moment an act declares the tag, the
; construe rule here is one line and the reactions are ready.)

; -- wrong-act, static wrongs (steal / defraud / embezzle / kidnap / expose /
; disinherit / coerce / humiliate / frame ...). Value gate: permissive when the
; act declares no (contradicts ..) or the patient's value substrate is silent;
; strict when the substrate speaks and says no.
(npc-reflex {?agent (construed-labels wrong-act) ?patient /ever}:?b
  (decl-of ?b contradicts):?v
  (when (or (not (substantial ?v))
            -{?patient value ?}
            {?patient value ?v}))
  (effects (construe ?b wrong-act ?agent ?patient)))

; -- wrong-act, violence (runtime blame - the fight-lane doctrine). Violent
; labels carry NO static wrong-act tag; blame is earned here unless the blow
; traces to prior violence against its own actor.
(npc-reflex {?attacker (theme-labels violent-to) ?victim /ever}:?belief
  (when (not (has-cause ?belief {? (theme-labels violent-to) ?attacker})))
  (decl-of ?belief contradicts):?v
  (when (or (not (substantial ?v))
            -{?victim value ?}
            {?victim value ?v}))
  (effects (construe ?belief wrong-act ?attacker ?victim)))

; -- intimacy-act: the standard construal PLUS betray-by-diversion - each
; exclusive-bond partner of the actor other than the act's patient is a
; betrayed party (the appraiser construes on their behalf; for the betrayed
; holder themselves ?victim binds @self and the patient-POV reactions fire).
(npc-reflex {?agent (construed-labels intimacy-act) ?patient /ever}:?b
  (effects (construe ?b intimacy-act ?agent ?patient)))

(npc-reflex {?agent (construed-labels intimacy-act) ?patient /ever}:?b
  (role ?victim {?agent (exclusive-bond-labels) ?victim}
        (not (eq ?victim ?patient)))
  (effects (construe ?b betray-act ?agent ?victim)))
