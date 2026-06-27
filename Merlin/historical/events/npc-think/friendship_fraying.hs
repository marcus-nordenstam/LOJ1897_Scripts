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
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational, gated on the detest stance + a friend bond, no co-presence). It
; fires MONTHLY now, so the per-pair (chance) is /12 (0.5 -> 0.04) to keep the
; fray gradual (a year's soured warmth settling rather than an instant snap).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event friendship_fraying
  (sim-window-start)
  (rng-stream friendships)

  ;; SELF-POV: @self reads only his OWN mind - his soured warmth toward ?b and his
  ;; own friend bond. (The bond is structural/mutual, so the effect drops it on both
  ;; sides, as befriend mints it on both.)
  (roles
    (role @self (template any_human)
             (adult-age @self))
    (role ?b (template any_human)
             (not (= ?b @self))
             ; @self now detests ?b (sustained strong-negative warmth, the floor
             ; warmth band - so the exact-band belief IS "warmth at least detest") ...
             (believes {@self detest ?b})
             ; ... and the two are currently friends.
             (believes {@self friend ?b})))

  ;; Live re-check: within the tick the role filters are alpha-indexed and go stale,
  ;; and a fray could have already severed this pair from the other direction. Re-
  ;; confirm the friend tie still holds, AND roll the per-pair fray chance here (/12
  ;; of the old annual 0.5) - a non-belief gate, so it lives in (when), not the role.
  (when (and (believes {@self friend ?b})
             (chance 0.04)))

  (effects
    ; Sever the mutual friend tie - the bond is structural, so both drop it.
    (end-belief @self friend ?b)
    (end-belief ?b friend @self)
    ))
