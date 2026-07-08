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

(hsim-npc-behaviour adult_friendship
  (long-term-think)
  (rng-stream friendships)

  (roles
    ; @self is the deliberating NPC (bound O(1)); ?b is enumerated underneath.
    ; The roles keep belief / template / self-exclusion filters - including the
    ; belief-pure perceived age-band predicates (adult-age / age-peers, which expand
    ; to age_band believes). Only the enthusiasm-scaled (chance) roll is non-belief
    ; and lives in the (when ...) clause below.
    (role @self (template any_human)
                (not (believes {@self repute [k scandalous]}))
                (adult-age @self))
    ;; SELF-POV (telepathy purge CAT-3): @self sizes up ?b from what HE knows -
    ;; ?b's repute / class as banded in via gossip / believe_about (3-arg
    ;; situation). The class match is positive, so @self only befriends a
    ;; same-class peer he is actually acquainted with (a stranger's class @fails);
    ;; the repute gate is permissive on the unknown. No cross-mind read.
    (role ?b (template any_human)
             (not (= ?b @self))
             (adult-age ?b)
             (age-peers @self ?b)
             (not (believes {?b repute [k scandalous]}))
             ; Same class: @self's belief that ?b's class matches his own (dynamic-
             ; target shape-2, cacheable - replaces the (= (target..)(target..)) pair).
             (believes {?b class_situation (target {@self class_situation})})
             (not (believes {@self friend ?b}))
             ; Warmth-gated: you do not befriend someone you actively dislike. The
             ; two negative warmth bands are EXPLICIT verb-state beliefs (core
             ; appraisal projects the warmth scalar onto them). Neutral same-class
             ; peers still pair (mere-exposure); only the two negative bands block.
             ; The pair excludes BOTH bands, since each `believes` is exact-band.
             (not (believes {@self dislike ?b}))
             (not (believes {@self detest ?b}))))

  ; Non-belief gate moved out of the @self role (role-belief-purity invariant):
  ; the enthusiasm-scaled (chance), rolled ONCE per @self per window.
  (when (chance (* 0.004 (+ 0.5 (attr @self enthusiasm)))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend @self ?b)
    ))
