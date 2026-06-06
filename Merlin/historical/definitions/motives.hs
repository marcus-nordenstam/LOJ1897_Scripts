; ----------------------------------------------------------------------------
; motives.hsc - motive vocabulary + driver matrix for the historical sim.
;
; An NPC's motives are derived from their situations (run_situation_pass),
; attitudes (toward other npcs), recent emotions, and static traits. Crime
; and social event templates declare which motives gate their perpetrator
; role; the binder prefers candidates whose computed motive set intersects
; the template's accepted motives.
;
; Form:
;   (motive <name>
;     (require situation         <flag>)
;     (require situation any_of  <a> <b> ...)
;     (require attitude_outgoing <kind>)
;     (require stance <dim> <band>)   ; a relational-stance band toward the
;                                     ; target (relational_stance_plan.md), e.g.
;                                     ; `warmth detest`. Replaces the retired
;                                     ; like/hate attitudes.
;     (require emotion_recent    <kind>)
;     (require trait <field> >= <N>)
;     (boost   situation <flag> +<n>)
;     (boost   trait <field> >= <N> +<n>))
;
; Trait convention: 128 is the population average for u8 traits. Multiple
; require clauses are AND'd. Boost clauses adjust strength above default 1.0.
; ----------------------------------------------------------------------------

;; === SELF-ORIENTED (8) =====================================================

(motive survival
  (require situation any_of starving destitute homeless)
  (boost   situation has_dependents +1))

(motive material_gain
  (require situation any_of poor in_debt financially_strained))

(motive fear_of_loss
  (require situation any_of business_failing reputation_threatened legacy_threatened)
  (boost   trait narcissism >= 160 +1)
  (boost   trait narcissism >= 200 +1))

(motive face_saving
  (require situation any_of publicly_humiliated reputation_threatened secret_at_risk)
  (boost   trait narcissism >= 160 +1)
  (boost   trait narcissism >= 200 +1))

(motive silence_witness
  (require situation witness_to_own_crime))

(motive social_climbing
  (require situation aspires_higher_class)
  (boost   trait machiavellianism >= 160 +1)
  (boost   trait narcissism       >= 160 +1))

(motive thrill
  (require trait psychopathy >= 128)
  (boost   trait psychopathy >= 160 +1)
  (boost   trait psychopathy >= 200 +2)
  (boost   trait sadism      >= 160 +1))

(motive compulsion
  (require trait psychopathy >= 128)
  (require trait sadism      >= 128)
  (boost   trait psychopathy >= 180 +1)
  (boost   trait psychopathy >= 220 +2)
  (boost   trait sadism      >= 180 +1)
  (boost   trait sadism      >= 220 +2))

;; === OTHER-ORIENTED (8) ====================================================

(motive family_preservation
  (require situation has_dependents)
  (require situation any_of family_threatened starving in_debt))

(motive mate_retention
  (require situation married)
  (require situation any_of suspects_infidelity rival_courting_spouse)
  (boost   trait machiavellianism >= 160 +1))

(motive mate_acquisition
  (require attitude_outgoing infatuation)
  (require situation rival_blocks_courtship))

(motive obsession
  (require attitude_outgoing infatuation)
  (require trait psychopathy >= 128)
  (boost   trait psychopathy >= 180 +1)
  (boost   trait narcissism  >= 160 +1))

(motive revenge
  ; was attitude_outgoing hate (retired); strong negative warmth (detest)
  ; toward the target is the disposition that drives revenge.
  (require stance warmth detest)
  (require situation was_wronged_by_target))

(motive vendetta
  (require situation family_was_wronged)
  (require stance warmth detest))

(motive domination
  (require trait sadism >= 128)
  (boost   trait sadism      >= 180 +1)
  (boost   trait sadism      >= 220 +2)
  (boost   trait psychopathy >= 160 +1))

(motive honor_defense
  (require situation any_of publicly_insulted family_dishonored))

;; === TRANSCENDENT (2) ======================================================

(motive ideology
  (require situation any_of class_resentful religious_zealot political_radical))

(motive mercy
  (require situation witness_to_suffering)
  (require emotion_recent compassion))
