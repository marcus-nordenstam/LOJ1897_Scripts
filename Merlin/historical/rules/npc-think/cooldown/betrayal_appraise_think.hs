; ----------------------------------------------------------------------------
; betrayal_appraise - the betrayal APPRAISAL, and ONLY the appraisal. On surfacing a
; partner's affair it mints the emotional reaction: anger @ the unfaithful partner,
; contempt @ the interloper, and a humiliation PRESSURE - all /caused_by the shared
; affair construal (appraise-betrayal, appraisal.cc, mints and pins them).
;
; It decides NO recourse. The recourse rules gate on what this minted:
;   - betrayal_kill reads the anger / contempt to pursue the LETHAL answer;
;   - affair_fallout reads the humiliation pressure to pursue the NON-lethal one
;     (confront / expose / divorce).
; Appraise ONCE per standing betrayal (guard: the anger not yet minted for this
; partner); a decayed reaction lets a persisting affair re-surface later.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think betrayal_appraise
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self )
  (role ?partner (any_human ?partner)
    {@self spouse|lover ?partner}
    (select (policy first-match)))
  (role ?interloper (any_human ?interloper)
    {?partner lover ?interloper}
    (none {?partner spouse ?interloper})
    (select (policy first-match)))

  ; The affair surfaces some months, not every one (probabilistic discovery).
  (when (and (none {@self emotion [k anger] ?partner})
             (chance 0.12)))
  (effects
    (appraise-betrayal ?partner ?interloper)))
