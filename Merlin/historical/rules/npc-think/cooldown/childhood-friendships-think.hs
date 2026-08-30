; ----------------------------------------------------------------------------
; Childhood friendships. Each school-aged child has a small chance to befriend a
; same-class peer within a few years of their own age.
;
; Topology: ?a is enumerated; ?b is sampled with backtracking from the
; population matching the per-pair filters. The (not (believes ...))
; filter prevents re-asserting an existing friendship.
;
; Friendships are bidirectional - both sides get a `friend` belief plus
; gender / death-status mirrors so a later "who are your friends?"
; query renders with detail.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think childhood_friendship
  (cooldown 1 m)
  (rng-stream friendships)

  ;; SELF-POV (telepathy purge CAT-3): @self the child befriends a peer he KNOWS -
  ;; the peer's class is read from @self's own view (3-arg situation, banded in via
  ;; believe_about), so a same-class match needs the two to be acquainted (an
  ;; unknown child's class @fails). No cross-mind read.
  (role @self
           (schoolchild-age @self)
           {@self age_band ?peer_band})
  (role ?b (any_human ?b)
           (schoolchild-age ?b)
           ; Same class: @self's belief that ?b's class matches his own (dynamic-
           ; target shape-2, cacheable - replaces the (= (target..)(target..)) pair).
           {?b class_situation (any {@self class_situation}).target}
           {?b age_span ?peer_band}
           -{@self friend ?b}
           ; Warmth-gated: see adult_friendships.hs. The two negative warmth
           ; bands (dislike, detest) are read as EXPLICIT verb-state beliefs
           ; (core appraisal projects the warmth scalar onto them) - kids rarely
           ; hold either yet, so volume is ~unchanged; the gate just prevents
           ; befriending an already-disliked peer. The pair excludes BOTH bands
           ; (= "warmth not below neutral"), since each `believes` is exact-band.
           -{@self dislike ?b}
           -{@self detest ?b})

  ; Non-belief gate moved out of the @self role: the enthusiasm-scaled chance.
  ; High enthusiasm (the sociable Extraversion aspect) makes friends more readily;
  ; mean-1.0 multiplier - friendship volume is unchanged.
  (when (chance (* 0.0125 (+ 0.5 (attr @self enthusiasm)))))

  (effects
    ; befriend mints the mutual tie (friend, or acquaintance if either side is
    ; already at friend-capacity) AND the matching-tier profile sync.
    (befriend @self ?b)
    ))
