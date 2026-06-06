; ----------------------------------------------------------------------------
; friendship_fraying (relational_stance_plan.md 5.2 / 12.6 follow-on).
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
; Reliability: ?b is intersected with the actor's `detest`-target BITSET
; (stance-at-least cross-pair, relational_stance_plan 13.1 - a tiny set) and
; confirmed a current friend via a `believes` residue; the per-pair (chance 0.5)
; makes the fray gradual rather than an instant snap. Both the believes residue
; and the non-root (chance ...) gate correctly since the hse non-root-residue
; fix (relational_stance_plan 13.2).
;
; Schedule: annually november - after friendships form (september) and
; ostracism resolves (october), so a year's soured warmth is settled at year
; end.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event friendship_fraying
  (nl       "?a and ?b drift apart")
  (kind     _friendship_fraying)
  (schedule (annually november))
  (rng-stream friendships)

  (roles
    (role ?a (template any_human)
             (>= (years-old ?a) 18))
    (role ?b (template any_human)
             (not (= ?b ?a))
             ; ?a now detests ?b (sustained strong-negative warmth) ...
             (stance-at-least ?a ?b detest)
             ; ... and the two are currently friends.
             (believes ?a {@self friend ?b})
             (chance 0.5)))

  ;; Live re-check: within the november tick the role filters are alpha-indexed
  ;; and go stale, and a fray could have already severed this pair from the
  ;; other direction. Re-confirm the friend tie still holds before ending it.
  (when (believes ?a {@self friend ?b}))

  (effects
    ; Sever the mutual friend tie - the bond is structural, so both drop it.
    (end-belief ?a friend ?b)
    (end-belief ?b friend ?a)
    (log _friendship_fraying ?a)))
