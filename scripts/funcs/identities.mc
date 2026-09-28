; ---- skill-driven trade / talent identities --------------------------------
; The COMPETENCE confers these, not the job title: a domain at `competent` or
; above on the pipeline-emitted {@self skill-level [k <domain>] [k <rung>]}.
; `competent` is the same rung position the retired C++ fold's `trained` held on
; the old 3-rung ladder - see thinks/classify/classify-calling.mc for that judgement call.
;
; DORMANT until acts decorated (track-skill-level <domain>) actually run - no
; skill-level belief exists in a 2-year run today, so none of these can fire yet.
;
; DIVERGENCE from the C++ fold, deliberate and flagged: that version walked the
; held domains and used else-if ordering per domain, so medicine beat the generic
; academic-field and music beat the generic performance-art FOR THAT DOMAIN. These
; folds test kinds independently, so an NPC competent in BOTH medicine and history
; reads as physician AND scholar (the C++ gave only physician). Revisit once real
; skill distributions exist - the fix wants a per-domain reduction, not more terms.
(define-func competent-in (?domain)
  (clamp (+ (prob {@self skill-level ?domain [k competent]})
            (prob {@self skill-level ?domain [k proficient]})
            (prob {@self skill-level ?domain [k virtuoso]})) 0.0 1.0))
