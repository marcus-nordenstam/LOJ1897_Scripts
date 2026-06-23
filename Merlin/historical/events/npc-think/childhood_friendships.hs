; ----------------------------------------------------------------------------
; Childhood friendships. Each school-aged child has a small chance to befriend a
; same-class peer within a few years of their own age.
;
; Topology: ?a is enumerated; ?b is sampled with backtracking from the
; population matching the per-pair filters. The (not (believes ...))
; filter prevents re-asserting an existing friendship.
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: same-class, near-age peers, no co-presence yet - kids' venue
; placement is a future refinement). MONTHLY now, so the ?a (chance) base is /12
; (0.15 -> 0.0125) to hold the annual childhood-friendship volume.
;
; Friendships are bidirectional - both sides get a `friend` belief plus
; gender / death-status mirrors so a later "who are your friends?"
; query renders with detail.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event childhood_friendship
  (sim-window-start)
  (nl         "?a and ?b become childhood friends")
  (rng-stream friendships)

  (roles
    ; High enthusiasm (the sociable Extraversion aspect) makes friends more
    ; readily. Mean-1.0 multiplier - friendship volume is unchanged.
    ;; SELF-POV (telepathy purge CAT-3): @self the child befriends a peer he KNOWS -
    ;; the peer's class is read from @self's own view (3-arg situation, banded in via
    ;; believe_about), so a same-class match needs the two to be acquainted (an
    ;; unknown child's class @fails). No cross-mind read.
    (role @self (template any_human)
             (>= (years-old @self) 8)
             (<= (years-old @self) 16)
             (chance (* 0.0125 (+ 0.5 (attr @self enthusiasm)))))
    (role ?b (template any_human)
             (>= (years-old ?b) 8)
             (<= (years-old ?b) 16)
             (not (= ?b @self))
             (= (target {?b class_situation}) (target {@self class_situation}))
             (<= (- (years-old ?b) (years-old @self))  3)
             (>= (- (years-old ?b) (years-old @self)) -3)
             (not (believes {@self friend ?b}))
             ; Warmth-gated: see
             ; adult_friendships.hs. Reliable cross-pair BITSET gates
             ; - kids rarely hold a dislike band yet, so volume is ~unchanged;
             ; the gate just prevents befriending an already-disliked peer.
             (not (stance-at-least @self ?b dislike))
             (not (stance-at-least @self ?b detest))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend @self ?b)
    (log _friendship @self)))
