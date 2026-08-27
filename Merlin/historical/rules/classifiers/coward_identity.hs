; ----------------------------------------------------------------------------
; coward identity (classifier). Toggles {@self identity [k role coward_role]} via
; mint-band: a single band at 0.5 IS a toggle (>= 0.5 begins, < 0.5 ends), and the
; held-scan matches only coward_role, so the other identities classify_identities
; mints (parent / worker / christian / gentleman / ...) are untouched.
;
; Fires on EITHER the timid-by-nature trait composite (low assertiveness AND high
; withdrawal) OR the cautious-by-conscience composite (high inhibition AND not
; exemplary) - the two routes to the same self-concept, deliberately permissive.
; Booleans compose as products of 0-or-1 terms; OR = (clamp (+ ...) 0 1). Gated on
; respectability_situation being derived (the !exemplary term is meaningful only
; then, and it is the adult-derive admission gate). Norm thresholds are the
; tunables below.
; ----------------------------------------------------------------------------

(define-macro coward-assert-max ()     0.35)   ; timid: assertiveness below this ...
(define-macro coward-withdraw-min ()   0.65)   ; ... AND withdrawal above this
(define-macro coward-inhibition-min () 0.70)   ; cautious: inhibition above this (0..1)

(npc-think classify_coward_identity
  (rng-stream behaviour)

  (role @self {@self repute ?})

  (effects
    (mint-band {@self identity}
      (clamp (+ (* (< (attr @self assertiveness) (coward-assert-max))
                   (> (attr @self withdrawal)    (coward-withdraw-min)))
                (* (> (inhibition) (coward-inhibition-min))
                   (- 1 (prob {@self repute [k repute exemplary]})))) 0 1)
      [k role coward_role] 0.5)))
