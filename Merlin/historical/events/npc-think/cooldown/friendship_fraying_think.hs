; ----------------------------------------------------------------------------
; friendship_fraying.
;
; The bond/affect split made durable on the negative side. A friend bond
; persists while warmth stays positive; until now it only ended on a wrong
; (the betray / abandonment reaction rows) or on scandal (social_ostracism).
; This ends it on SUSTAINED low warmth: the leaky stance integrator has dragged
; the actor's warmth toward the friend all the way into the `detest` band (-2 -
; the strong, hysteresis-stable negative; a transient dip into `dislike` does
; NOT qualify), so the friendship quietly dissolves. The estranged-friend case
; the stance vector exists to model.
;
; Gated on `detest`, not mere `dislike`: a friendship survives coolness; only a
; hardened, sustained dislike severs it. The tie is structural and mutual, so
; both sides drop it (cf. social_ostracism, which ends warmth bonds on both
; sides).
;
; Reliability: ?b is gated on the actor's `detest` warmth band - read as an
; EXPLICIT verb-state belief (core appraisal projects the warmth scalar onto the
; band; detest is the floor band, so the exact-band belief IS "warmth at least
; detest") - and confirmed a current friend via a `believes` residue; the per-pair
; (chance 0.5) makes the fray gradual rather than an instant snap. Both the
; believes residue and the non-root (chance ...) gate correctly.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think friendship_fraying
  (cooldown 1 m)
  (rng-stream friendships)

  ;; SELF-POV: @self reads only his OWN mind - his soured warmth toward ?b and his
  ;; own friend bond. (The bond is structural/mutual, so the effect drops it on both
  ;; sides, as befriend mints it on both.)
  (role @self (adult-age @self))
  (role ?b (any_human ?b)
           ; @self now detests ?b (sustained strong-negative warmth, the floor
           ; warmth band - so the exact-band belief IS "warmth at least detest") ...
           (believes {@self detest ?b})
           ; ... and the two are currently friends.
           (believes {@self friend ?b}))

  ;; The role's believes filters (detest, friend) are re-checked live at the
  ;; when-gate seam within the tick - the alpha index goes stale and a fray could
  ;; already have severed this pair from the other direction, so the live re-check
  ;; preserves the hold. (when) carries only the per-pair fray (chance) - /12 of the
  ;; annual 0.5 - a non-belief gate, so it never sits in the role.
  (when (chance 0.04))

  (effects
    ; Sever the mutual friend tie - the bond is structural, so both drop it.
    (end-belief {@self friend ?b})
    (end-belief ?b {?b friend @self})
    ))
