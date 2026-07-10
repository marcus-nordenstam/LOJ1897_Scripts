; ----------------------------------------------------------------------------
; advantageous_match (Phase 9.3). An exemplary woman may marry above her
; class. Where the ordinary `betrothal` event requires class parity between
; bride and groom, this event relaxes the ceiling for a bride whose
; respectability_situation is `exemplary` - a spotless reputation is the
; recognised lift over a one-class-above match.
;
; The mechanics mirror betrothal: assert the symmetric {fiancee} beliefs +
; mutual believe-about, so the existing wedding event consumes the couple
; the same way it consumes betrothal's output. Re-fire is guarded by the
; (not (believes ...)) filter on both bride and groom.
;
; Schedule: annually february, after betrothal (january) has had its first
; pass - so the exemplary candidates left un-betrothed by the parity matcher
; still get a shot, without two betrothal verbs competing for the same
; candidates within one tick.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour advantageous_match
  (long-term-think)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY; the per-bride (chance) is scaled by /12 (the *0.0833 wrapper) to hold
  ; the old annual rate.
  (rng-stream marriages)

  (roles
    ;; Exemplary bride: spotless reputation lifts her one class up.
    ;; The plan's "infatuation-target overlap or parental matchmaking
    ;; pressure" motivations are V2 work - infatuation substrate ships
    ;; with PR-A-9 (crush_forms.hse), parental matchmaking pressure
    ;; needs the parent's life_aim plus child's current courtship state
    ;; (multi-role join, deferred). V1 substrate-routes the chance via a
    ;; trait product over (enthusiasm + openness) - outgoing brides
    ;; engage in seasonal courtship rituals more than withdrawn ones;
    ;; the constraint filters (exemplary respectability + age gap +
    ;; class compatibility on the groom side) are already substrate-
    ;; rooted, so the multiplicative chance just adds a smooth
    ;; trait-driven gradient on top.
    ;; SELF-POV (telepathy purge CAT-3): @self the GROOM is the deliberator (light
    ;; @self template + inline gates; the man proposes). He marries DOWN one class to
    ;; an exemplary woman he KNOWS - her exemplary repute / class read from his own
    ;; view ((situation ?bride <dim> @self)), her availability his own belief. The
    ;; non-belief gates (the (chance) trait-graded pacing and the groom gender read)
    ;; now live in (when); the role keeps the belief-pure availability / repute
    ;; filters plus the perceived age-peer + blood-kin predicates (belief macros).
    (role @self (adult @self)
                (not (believes {@self spouse ?}))
                (not (believes {@self fiancee ?}))
                (not (believes {@self repute [k scandalous]}))
                (not (believes {@self repute [k disreputable]})))
    ;; An exemplary bride one class BELOW the groom (spotless reputation lifts her).
    ;; class_situation values are upper / middle / lower; the explicit kind literals
    ;; dodge the ambiguous bare-atom path. The (or ...) encodes the two valid lifts.
    ;; age-peers / blood-kin are belief-pure perceived predicates, so they stay role
    ;; filters (cacheable), gating the bride candidate set directly.
    (role ?bride (unmarried_woman ?bride)
                 (not (= ?bride @self))
                 (age-peers @self ?bride)
                 (not (blood-kin @self ?bride))
                 (not (believes {?bride fiancee ?}))
                 (believes {?bride repute [k exemplary]})
                 (or (and (believes {@self class_situation [k middle]})
                          (believes {?bride class_situation [k lower]}))
                     (and (believes {@self class_situation [k upper]})
                          (believes {?bride class_situation [k middle]})))))

  ;; Live exclusivity re-check (see betrothal.hs), from the groom's OWN beliefs.
  ;; Non-belief gates moved out of the roles: the (chance) pacing (first - it
  ;; short-circuits the additive trait product) and the groom gender read. (when)
  ;; evaluates ops for @self and sees the cast ?bride role var, so they work here.
  (when (and (chance (* 0.0833
                        (+ 0.20
                           (* 0.4 (attr @self enthusiasm))
                           (* 0.4 (attr @self openness)))))
             (not (believes {@self fiancee ?}))
             (not (believes {?bride fiancee ?}))
             (= (attr @self gender) [k male])))

  (effects
    (begin-belief {@self fiancee ?bride})
    ; The bride's own engagement belief lands in HER mind (wedding recovers the
    ; groom from the bride's fiancee belief, either side initiating).
    (begin-belief ?bride {?bride fiancee @self})
    (believe-about @self ?bride)
    (believe-about ?bride @self)
    ))
