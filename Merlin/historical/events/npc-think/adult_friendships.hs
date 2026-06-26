; ----------------------------------------------------------------------------
; Adult friendships (npc-think). Lower per-person rate than childhood - adults
; make friends less often once kin / work / marriage already structure their
; social orbit.
;
; Topology: ?a is enumerated; ?b is sampled with backtracking from same-class
; adults within ten years of age who are not already ?a's friend. The (not
; (believes ...)) filter prevents re-asserting an existing friendship.
;
; A mental change (a new bond), so npc-think. Fired by the per-NPC emergent pass
; (relational: same-class, near-age, warmth-gated). RELATIONAL - physical
; co-presence is not required; a place-lane "befriend at a venue" form (preset ?a
; from a venue's occupants) is a future refinement. MONTHLY now, so the ?a
; (chance) base is /12 (0.05 -> 0.004) to hold the annual adult-friendship volume.
;
; Friendships are bidirectional - befriend mints both sides' `friend` belief plus
; the matching-tier profile sync so a later "who are your friends?" query renders
; with detail.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event adult_friendship
  (sim-window-start)
  (rng-stream friendships)

  (roles
    ; @self is the deliberating NPC (bound O(1)); ?b is enumerated underneath.
    ; Enthusiasm (the sociable Extraversion aspect) makes friends more readily.
    ; Mean-1.0 multiplier on the /12 base - adult-friendship volume is unchanged.
    ; The chance lives on the @self role, so it is rolled ONCE per NPC per window
    ; (before ?b enumeration), not once per candidate.
    (role @self (template any_human)
                (>= (years-old @self) 18)
                (not (believes {@self repute [k scandalous]}))
                (chance (* 0.004 (+ 0.5 (attr @self enthusiasm)))))
    ;; SELF-POV (telepathy purge CAT-3): @self sizes up ?b from what HE knows -
    ;; ?b's repute / class as banded in via gossip / believe_about (3-arg
    ;; situation). The class match is positive, so @self only befriends a
    ;; same-class peer he is actually acquainted with (a stranger's class @fails);
    ;; the repute gate is permissive on the unknown. No cross-mind read.
    (role ?b (template any_human)
             (>= (years-old ?b) 18)
             (not (= ?b @self))
             (not (believes {?b repute [k scandalous]}))
             (= (target {?b class_situation}) (target {@self class_situation}))
             (<= (- (years-old ?b) (years-old @self))  10)
             (>= (- (years-old ?b) (years-old @self)) -10)
             (not (believes {@self friend ?b}))
             ; Warmth-gated: you do not befriend someone you actively dislike
             ; (reliable cross-pair BITSET). Neutral same-class peers still pair
             ; (mere-exposure); only the two negative warmth bands block.
             (not (stance-at-least @self ?b dislike))
             (not (stance-at-least @self ?b detest))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend @self ?b)
    ))
