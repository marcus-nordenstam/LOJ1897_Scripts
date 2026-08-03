; ----------------------------------------------------------------------------
; social_ostracism (per-observer). The Victorian "social death", modelled the
; way it actually happens: each townsman severs his OWN warmth ties to a person
; HE has come to repute `scandalous`. There is no self-repute-driven mass
; severing and no cross-mind read - a scandalous man loses a given friend only
; if and when that friend's OWN repute of him falls to scandalous (through
; witnessed acts, gossip, or reading). The bond is structural and mutual, so
; dropping it ends both sides, exactly as befriend mints both (cf.
; friendship_fraying, which severs on sustained detest the same way).
;
; Warmth bonds only (friend / close_to). relied_on_by / respected_by (utility),
; job and family bonds are untouched - ostracism is social, not vocational or
; filial.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think social_ostracism
  (cooldown 1 m)
  (rng-stream behaviour)

  ; SELF-POV: @self shuns a warmth-tie he reputes scandalous. ?b is a current
  ; friend / close_to whom @self's OWN repute belief bands scandalous - his belief
  ; about ?b, never a read of ?b's mind.
  (role @self (adult-age @self))
  (role ?b (any_human ?b)
           (believes {?b repute [k scandalous]})
           (or (believes {@self friend ?b})
               (believes {@self close_to ?b})))

  ; ~annual cadence per soured tie; a non-belief gate, so it lives in (when).
  (when (chance 0.0833))

  (effects
    (end-belief @self friend ?b)
    (end-belief ?b friend @self)
    (end-belief @self close_to ?b)
    (end-belief ?b close_to @self)
    ))
