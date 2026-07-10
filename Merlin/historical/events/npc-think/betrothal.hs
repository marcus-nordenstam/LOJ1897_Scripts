; ----------------------------------------------------------------------------
; Betrothal. The matching half of the old single-event marriage: for each
; unmarried, un-betrothed adult woman, with a small annual chance, sample an
; unmarried, un-betrothed adult man whose age is within 15 years and whose
; class matches. It sets the {fiancee} bond on the couple only; the wedding
; (a separate event, five months later) consumes betrothed couples.
;
; Schedule: (annually january) - the pre-industrial pattern was for banns and
; parish marriages to cluster around new year; betrothal leads the wedding.
;
; Topology: ?bride is independent (role[0], enumerated). ?groom depends on
; ?bride's age and class via filters that reference ?bride.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think betrothal
  (long-term-think)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY, so the per-bride (chance) is /12 of the old annual 0.25 (-> 0.0208)
  ; to hold the annual betrothal rate. Betrothals spread year-round now (the
  ; historical new-year season could be re-added later as a seasonal chance
  ; multiplier). The wedding occasion (already emergent) consumes betrothed couples
  ; monthly; engagement_party announces in the short gap between.
  (rng-stream marriages)

  ;; SELF-POV (telepathy purge CAT-3): @self the GROOM is the deliberator (the POV
  ;; NPC is bound, never enumerated; he uses a LIGHT @self template + inline gates -
  ;; the heavy unmarried_man template is for BINDING roles). He proposes to a bride
  ;; he KNOWS, judging her ONLY from his own knowledge: her repute / class /
  ;; reputed_chastity as banded in via the venue acquaintance channel
  ;; ((situation ?bride <dim> @self)), her availability as his own belief
  ;; ((believes {?bride <label> ?}), permissive on the unknown). The market reads
  ;; `repute` / `reputed_chastity` - what has LEAKED - never secret self-values.
  (role @self (adult @self)
              (not (believes {@self spouse ?}))
              (not (believes {@self fiancee ?}))
              (not (believes {@self repute [k scandalous]}))
              (not (believes {@self repute [k disreputable]})))
  (role ?bride (unmarried_woman ?bride)
               (not (= ?bride @self))
               ;; Not already spoken-for (he avoids a woman he KNOWS is engaged or
               ;; attached; a secret he has not heard does not stop the match).
               (not (believes {?bride fiancee ?}))
               (not (believes {?bride lover ?}))
               ;; A fallen woman (divorced for adultery) is shut out absolutely.
               (not (believes {?bride prototype [k fallen_woman]}))
               (not (believes {?bride repute [k scandalous]}))
               (not (believes {?bride repute [k disreputable]}))
               ;; Not KNOWN to be disgraced (two+ leaked affairs). An unread
               ;; chastity passes - the market gives the benefit of the doubt
               ;; (the old `(>= reputed_chastity 0.5) OR unread` gate, now a
               ;; single negated band belief: disgraced is the sub-0.5 band).
               (not (believes {?bride reputed_chastity [k disgraced]}))
               ;; Same class as the groom: the deliberating mind's belief that
               ;; the bride's class_situation equals @self's own (dynamic-target
               ;; shape-2, cacheable - like age-peers; NOT a cross-(target =)).
               (believes {?bride class_situation (target {@self class_situation})})
               ;; Belief-pure perceived predicates - the near-age window and the
               ;; blood-kin exclusion - stay role filters (cacheable), gating the
               ;; bride candidate set directly.
               (age-peers @self ?bride)
               (not (blood-kin @self ?bride)))

  ;; Exclusivity re-check at FIRING time, from the groom's OWN beliefs (his own
  ;; engagement + what he knows of hers). A same-tick double-betroth by two grooms
  ;; who BOTH do not yet know is left to a future public-blackboard claim.
  ;; ROLE-PURITY: the non-belief gates moved out of the roles live here - the
  ;; per-groom (chance) (first, short-circuits), the male gender read, and the
  ;; same-station-lover impediment (a lover whose class equals his keeps him out
  ;; of the arranged market; such pairs wed via love_match - no lover -> @fail ->
  ;; the (and ...) is false -> eligible). (age-peers / blood-kin are belief-pure
  ;; and stay in the ?bride role.)
  (when (and (chance 0.0208)
             (not (believes {@self fiancee ?}))
             (not (believes {?bride fiancee ?}))
             (= (attr @self gender) [k male])
             (not (and (believes {@self lover ?})
                       (= (target {(target {@self lover}) class_situation})
                          (target {@self class_situation}))))))

  (effects
    (begin-belief {@self fiancee ?bride})
    ; The bride's own engagement belief lands in HER mind (the wedding event
    ; recovers the groom from the bride's fiancee belief, either side initiating).
    (begin-belief ?bride {?bride fiancee @self})
    ; Each betrothed learns the other's social profile - see hsim::believe_about.
    (believe-about @self ?bride)
    (believe-about ?bride @self)
    ))
