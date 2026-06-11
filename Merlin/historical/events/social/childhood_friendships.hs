; ----------------------------------------------------------------------------
; Childhood friendships. Once a year (in march), each school-aged child has
; a small chance to befriend a same-class peer within a few years of their
; own age.
;
; Topology: ?a is enumerated; ?b is sampled with backtracking from the
; population matching the per-pair filters. The (not (believes ...))
; filter prevents re-asserting an existing friendship.
;
; Friendships are bidirectional - both sides get a `friend` belief plus
; gender / death-status mirrors so a later "who are your friends?"
; query renders with detail.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event childhood_friendship
  (nl         "?a and ?b become childhood friends")
  (kind       _friendship)
  (schedule   (annually march))
  (band      afternoon)
  (rng-stream friendships)

  (roles
    ; High enthusiasm (the sociable Extraversion aspect) makes friends more
    ; readily. Mean-1.0 multiplier - friendship volume is unchanged.
    (role ?a (template any_human)
             (>= (years-old ?self) 8)
             (<= (years-old ?self) 16)
             (chance (* 0.15 (+ 0.5 (attr ?self enthusiasm)))))
    (role ?b (template any_human)
             (>= (years-old ?self) 8)
             (<= (years-old ?self) 16)
             (not (= ?self ?a))
             (= (belief-target ?self class_situation) (belief-target ?a class_situation))
             (<= (- (years-old ?self) (years-old ?a))  3)
             (>= (- (years-old ?self) (years-old ?a)) -3)
             (not (believes ?a {@self friend ?b}))
             ; Warmth-gated: see
             ; adult_friendships.hs. Reliable cross-pair BITSET gates
             ; - kids rarely hold a dislike band yet, so volume is ~unchanged;
             ; the gate just prevents befriending an already-disliked peer.
             (not (stance-at-least ?a ?b dislike))
             (not (stance-at-least ?a ?b detest))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend ?a ?b)
    (log _friendship ?a)))
