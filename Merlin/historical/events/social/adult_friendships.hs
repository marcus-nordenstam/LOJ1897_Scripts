; ----------------------------------------------------------------------------
; Adult friendships. Lower per-person rate than childhood - adults make
; friends less often once kin / work / marriage already structure their
; social orbit.
;
; Topology: ?a enumerated; ?b sampled from same-class adults within 10
; years of age who are not already ?a's friend.
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: same-class, near-age, warmth-gated; physical co-presence not
; required - a place-lane "befriend at a venue" form is a future refinement).
; MONTHLY now, so the ?a (chance) base is /12 (0.05 -> 0.004) to hold volume.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event adult_friendship
  (nl         "?a and ?b become friends")
  (kind       _friendship)
  (band      afternoon)
  (rng-stream friendships)

  ; PLACE-EMERGENT (Section 4.11): a friendship forms between two people who SHARE
  ; A VENUE this band (pub, club, church, the workplace, ...), via the
  ; `adult_friendship` affordance. ?a is PRESET from the venue's occupants, so its
  ; eligibility (adult, not scandalous) moves to the (when) gate. Friend slots are
  ; decade-paced (friend_allowance), so work co-presence competes for the slots
  ; that open as the NPC ages - the work share emerges, no quota needed.
  (roles
    (role ?a (template any_human))
    (role ?b (template any_human)
             (>= (years-old ?self) 18)
             (not (= ?self ?a))
             (not (= (situation ?self repute) scandalous))
             (= (situation ?self class_situation) (situation ?a class_situation))
             (<= (- (years-old ?self) (years-old ?a))  10)
             (>= (- (years-old ?self) (years-old ?a)) -10)
             ; the friendship forms with whoever shares the venue this band.
             (co-present ?a ?b)
             (not (believes ?a {@self friend ?b}))
             ; Warmth-gated: you do not befriend someone you actively dislike
             ; (reliable cross-pair BITSET). Neutral same-class peers still pair
             ; (mere-exposure); only the two negative warmth bands block.
             (not (stance-at-least ?a ?b dislike))
             (not (stance-at-least ?a ?b detest))))

  ;; Actor eligibility (preset role-0 skips role filters): an adult of sound
  ;; standing; enthusiasm (the sociable aspect) makes the outgoing befriend more.
  (when (and (>= (years-old ?a) 18)
             (not (= (situation ?a repute) scandalous))
             (chance (+ 0.3 (attr ?a enthusiasm)))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend ?a ?b)
    (log _friendship ?a)))
