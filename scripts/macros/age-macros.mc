; ----------------------------------------------------------------------------
; age_macros.mc - perceptible age-band predicates, as define-macros.
;
; A man reads his OWN age as a number, {@self age <years>}. Of others every mind
; holds a PERCEIVED age-band belief about the people it has seen - {?o age-band
; <band>} - minted on sight (perceive_person_appearance), even for strangers. The
; exact birth-date is communicated only to friends-and-closer. So role filters test
; another's band, never a specific age.
;
; The ladder (concepts.mon `age-band`, C++ age_band_index is the source of truth):
;   infant 0-2 < child 3-9 < adolescent 10-15 < youth 16-17 < young-adult 18-29
;   < middle-aged 30-49 < mature 50-69 < elderly 70+
; Narrow under 30, wide at 30+ - so "same / adjacent band" (age-peers) stands in
; for the old numeric age-diff windows: tight among the young, loose among adults.
;
; THRESHOLD predicates expand to a BARE pattern with a ground KIND-ALT target
; (`[k a|b|c]`): true iff @self perceives ?o in ANY of those bands. In a role the
; pattern IS the cached role grammar; in (when)/(and) frames it coerces to the
; belief-existence test. The alt-list MUST stay in lockstep with the ladder above.
; ----------------------------------------------------------------------------




; AGE-PEER CHECK (no macro - the check is inlined by each caller). "Are @self and
; ?other in the SAME or an ADJACENT band?" = is @self's age-band within ?other's
; perceived age-span (its band +/- 1). The ladder is narrow when young and wide when
; old, so that is ~a few years among children and ~a generation among adults.
;
; This CANNOT be a one-call (believes ...) macro. age-span is a PLURAL belief, and an
; inline (any {@self age-band}).target in its target slot does NOT resolve against it (it
; matches only SINGLE @excl beliefs, e.g. gender / class-situation). The band must be
; a BOUND variable, and the bind must live in the @self role (evaluated once for the
; deliberating self) - binding in the ?other role re-binds per candidate. Each caller
; uses:
;   (role @self  ... (believes {@self  age-band ?peer_band}))
;   (role ?other ... (believes {?other age-span ?peer_band}))
