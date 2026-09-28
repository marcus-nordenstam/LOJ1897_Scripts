; ----------------------------------------------------------------------------
; construe_acts (reflex, appraise phase) - the construal doctrine.
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

(reflex {?agent (construed-labels harm-act) ?patient /ever}:?harm-act
  (effects (construe ?harm-act harm-act ?agent ?patient)))

(reflex {?agent (construed-labels appropriation-act) ?patient /ever}:?appropriation-act
  (effects (construe ?appropriation-act appropriation-act ?agent ?patient)))

(reflex {?agent (construed-labels suffer-loss-act) ?patient /ever}:?suffer-loss-act
  (effects (construe ?suffer-loss-act suffer-loss-act ?agent ?patient)))

(reflex {?agent (construed-labels coercion-act) ?patient /ever}:?coercion-act
  (effects (construe ?coercion-act coercion-act ?agent ?patient)))

(reflex {?agent (construed-labels threaten-act) ?patient /ever}:?threaten-act
  (effects (construe ?threaten-act threaten-act ?agent ?patient)))

(reflex {?agent (construed-labels slight-act) ?patient /ever}:?slight-act
  (effects (construe ?slight-act slight-act ?agent ?patient)))

(reflex {?agent (construed-labels rivalrous-act) ?patient /ever}:?rivalrous-act
  (effects (construe ?rivalrous-act rivalrous-act ?agent ?patient)))

(reflex {?agent (construed-labels betray-act) ?patient /ever}:?betray-act
  (effects (construe ?betray-act betray-act ?agent ?patient)))

(reflex {?agent (construed-labels degrade-act) ?patient /ever}:?degrade-act
  (effects (construe ?degrade-act degrade-act ?agent ?patient)))

(reflex {?agent (construed-labels expose-act) ?patient /ever}:?expose-act
  (effects (construe ?expose-act expose-act ?agent ?patient)))

(reflex {?agent (construed-labels abandonment-act) ?patient /ever}:?abandonment-act
  (effects (construe ?abandonment-act abandonment-act ?agent ?patient)))

(reflex {?agent (construed-labels honour-act) ?patient /ever}:?honour-act
  (effects (construe ?honour-act honour-act ?agent ?patient)))

; (No construe rules for help-act / aid-act / provision-act / commitment-act /
; repudiation-act: NO hsim label carries those tags today - a (construed-labels
; <tag>) gate over an empty family is a load error, deliberately. Their REACT
; rows in reactions.mc stay authored: the moment an act declares the tag, the
; construe rule here is one line and the reactions are ready.)

; -- wrong-act, static wrongs (steal / defraud / embezzle / kidnap / expose /
; disinherit / coerce / humiliate ...). Value gate: permissive when the
; act declares no (contradicts ..) or the patient's value substrate is silent;
; strict when the substrate speaks and says no.
(reflex {?agent (construed-labels wrong-act) ?patient /ever}:?wrong-act
  (decl-of ?wrong-act contradicts):?v
  (when (or (not (substantial ?v))
            -{?patient value ?}
            {?patient value ?v}))
  (effects (construe ?wrong-act wrong-act ?agent ?patient)))

; wrong-act, violence (runtime blame - the fight-aspect doctrine). Violent
; labels carry NO static wrong-act tag; blame is earned here unless the blow
; traces to prior violence against its own actor.
(reflex {?attacker (theme-labels violent-to) ?victim /ever}:?violent-to
  (when (not (has-cause ?violent-to {? (theme-labels violent-to) ?attacker})))
  (decl-of ?violent-to contradicts):?v
  (when (or (not (substantial ?v))
            -{?victim value ?}
            {?victim value ?v}))
  (effects (construe ?violent-to wrong-act ?attacker ?victim)))

; -- intimacy-act: the standard construal PLUS betray-by-diversion - each
; exclusive-bond partner of the actor other than the act's patient is a
; betrayed party (the appraiser construes on their behalf; for the betrayed
; holder themselves ?victim binds @self and the patient-POV reactions fire).
(reflex {?agent (construed-labels intimacy-act) ?patient /ever}:?intimacy-act
  (effects (construe ?intimacy-act intimacy-act ?agent ?patient)))

(reflex {?agent (construed-labels intimacy-act) ?patient /ever}:?intimacy-act
  (role ?victim {?agent (exclusive-bond-labels) ?victim}
        (not (eq ?victim ?patient))
    (effects (construe ?intimacy-act betray-act ?agent ?victim))))
