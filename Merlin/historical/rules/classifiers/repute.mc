; ----------------------------------------------------------------------------
; repute (per-observer). Each mind bands a person's public respectability into
; {X repute [k repute ...]} from (repute-fold X) - the seven-term mean over that
; person's conduct bands + devoutness + decorum + per-observer chastity
; (dimensions.hs). ONE fold, ONE belief, serving both cases; the only difference
; is which mind's inputs it reads, never the algorithm:
;   - classify_self_repute:   {@self repute}   from @self's OWN inputs, which are
;                             complete - so self-repute IS the truth (mint-band).
;   - classify_others_repute: {?other repute}  from only what @self has learned of
;                             them (mint-band-about, landing in @self's own pool).
;
; Reputation is per-observer and non-telepathic: two minds hold different repute
; of the same third party, a stranger reads middling (fair defaults), and an
; observer with only negative evidence caps a person below exemplary - you do not
; credit a prestige-marriage-grade character to someone you know nothing good
; about. There is no separate "true respectability" label; the gap that used to be
; called the blackmail stake is just the difference between what a mind knows of
; itself and what others have learned. (Bands: the historical respectability
; thresholds.)
; ----------------------------------------------------------------------------

(npc-think classify_self_repute
  ; The fully-banded fuse over the seven repute-fold terms: four conduct bands +
  ; devoutness + decorum + chastity-scalar (lover count); a band drops when its
  ; evidence is forgotten. class_situation being derived is the eligibility gate,
  ; not a fold input.
  (rng-stream behaviour)

  (role @self {@self class_situation ?})

  (effects
    (mint-band {@self repute} (repute-fold @self)
      [k repute exemplary]    0.80
      [k repute respectable]  0.60
      [k repute questionable] 0.40
      [k repute disreputable] 0.20
      [k repute scandalous]   -1)))

(npc-think classify_others_repute
  ; Per-observer fuse: re-bands ?other's repute from the conduct band / devoutness /
  ; decorum / lover beliefs @self holds ABOUT them. class_situation is the gate.
  (rng-stream behaviour)

  (role ?other {?other class_situation ?})

  (effects
    (mint-band-about {?other repute} (repute-fold ?other)
      [k repute exemplary]    0.80
      [k repute respectable]  0.60
      [k repute questionable] 0.40
      [k repute disreputable] 0.20
      [k repute scandalous]   -1)))
