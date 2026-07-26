; ----------------------------------------------------------------------------
; Betrothal. The matching half of the old single-event marriage: for each
; unmarried, un-betrothed adult woman, with a small annual chance, sample an
; unmarried, un-betrothed adult man whose age is within 15 years and whose
; class matches. It sets the {fiancee} bond on the couple only; the wedding
; (a separate event, five months later) consumes betrothed couples.
;
; Topology: ?bride is independent (role[0], enumerated). ?groom depends on
; ?bride's age and class via filters that reference ?bride.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think betrothal
  (cooldown 1 m)
  (rng-stream marriages)

  ;; SELF-POV (telepathy purge CAT-3): @self the GROOM is the deliberator (the POV
  ;; NPC is bound, never enumerated; he uses a LIGHT @self template + inline gates -
  ;; the heavy unmarried_man template is for BINDING roles). He proposes to a bride
  ;; he KNOWS, judging her ONLY from his own knowledge: her repute / class as
  ;; banded in via the venue acquaintance channel, her chastity from the liaisons
  ;; HE has heard of ((count-beliefs-about ?bride lover) - per-observer, never an
  ;; omniscient public reading), her availability as his own belief
  ;; ((believes {?bride <label> ?}), permissive on the unknown).
  (role @self (adult @self)
              (believes {@self gender [k male]})
              (not (believes {@self spouse ?}))
              (not (believes {@self fiancee ?}))
              (not (believes {@self repute [k scandalous]}))
              (not (believes {@self repute [k disreputable]})))
  (role ?bride (unmarried_woman ?bride)
               ;; Not already spoken-for (he avoids a woman he KNOWS is engaged or
               ;; attached; a secret he has not heard does not stop the match).
               (not (believes {?bride fiancee ?}))
               (not (believes {?bride lover ?}))
               ;; A fallen woman (divorced for adultery) is shut out absolutely.
               (not (believes {?bride prototype [k fallen_woman]}))
               (not (believes {?bride repute [k scandalous]}))
               (not (believes {?bride repute [k disreputable]}))
               ;; (The chastity gate moved to (when) - per-observer, a count of the
               ;; liaisons the groom himself has heard of; line 45 already bars a known
               ;; ONGOING lover.)
               ;; Same class as the groom: the deliberating mind's belief that
               ;; the bride's class_situation equals @self's own (dynamic-target
               ;; shape-2, cacheable - like age-peers; NOT a cross-(target =)).
               (believes {?bride class_situation (target {@self class_situation})})
               ;; Belief-pure perceived predicates - the near-age window and the
               ;; blood-kin exclusion - stay role filters (cacheable), gating the
               ;; bride candidate set directly.
               (age-peers @self ?bride)
               (not (blood-kin @self ?bride)))

  ;; Only the non-cacheable gates stay live: the per-groom (chance) pacing and
  ;; the same-station-lover impediment (a lover whose class equals his keeps him
  ;; out of the arranged market; such pairs wed via love_match - no lover ->
  ;; @fail -> the (and ...) is false -> eligible). Exclusivity and gender ARE
  ;; the role/self-gate filters (the cache reconciles at belief-write; a live
  ;; re-read of the same store cannot differ).
  (when (and (chance 0.0208)
             ;; Not KNOWN to be disgraced: fewer than two liaisons the groom himself
             ;; has heard of (per-observer chastity, any tense). A bride whose past he
             ;; has not heard passes - the market gives the benefit of the doubt.
             (< (count-beliefs-about ?bride lover) 2)
             (not (and (believes {@self lover ?})
                       (= (target {(target {@self lover}) class_situation})
                          (target {@self class_situation}))))))

  (effects
    (begin-belief {@self fiancee ?bride})
    ; The bride's own engagement belief lands in HER mind (the wedding event
    ; recovers the groom from the bride's fiancee belief, either side initiating).
    (begin-belief ?bride {?bride fiancee @self})
    ; @self (the groom) discloses his friend-tier profile to the bride (the SAY she
    ; hears and adopts) - the honest replacement for the believe_about profile-copy,
    ; delivered by co-presence. His own knowledge of her pre-exists from courtship.
    (for-each-belief ?fact {@self (disclosure-tier-labels friend) ?}
      (tell-to ?bride (utterable-msg (to ?bride) ?fact)))
    ))
