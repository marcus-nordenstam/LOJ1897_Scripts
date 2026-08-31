; ----------------------------------------------------------------------------
; advantageous_match (Phase 9.3). An exemplary woman may marry above her
; class. Where the ordinary `betrothal` rule requires class parity between
; bride and groom, this rule relaxes the ceiling for a bride whose
; respectability_situation is `exemplary` - a spotless reputation is the
; recognised lift over a one-class-above match.
;
; The mechanics mirror betrothal: assert the symmetric {fiancee} beliefs +
; mutual believe-about, so the existing wedding rule consumes the couple
; the same way it consumes betrothal's output. Re-fire is guarded by the
; (not (believes ...)) filter on both bride and groom.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think advantageous_match
  (cooldown 1 m)
  (rng-stream marriages)

  ;; Exemplary bride: spotless reputation lifts her one class up.
  ;; The plan's "infatuation-target overlap or parental matchmaking
  ;; pressure" motivations are V2 work - infatuation substrate ships
  ;; with PR-A-9 (crush_forms.hse), parental matchmaking pressure
  ;; needs the parent's life-aim plus child's current courtship state
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
  ;; view ({?bride <dim> ?} own-belief filters), her availability his own belief. The
  ;; non-belief gate (the (chance) trait-graded pacing) lives in (when); the role
  ;; keeps the belief-pure availability / repute / gender filters plus the
  ;; perceived age-peer + blood-kin predicates (belief macros).
  (role @self (adult @self)
              {@self gender [k male]}
              -{@self spouse ?}
              -{@self fiancee ?}
              -{@self repute [k scandalous]}
              -{@self repute [k disreputable]}
              {@self age-band ?peer_band})
  ;; An exemplary bride one class BELOW the groom (spotless reputation lifts her).
  ;; class-situation values are upper / middle / lower; the explicit kind literals
  ;; dodge the ambiguous bare-atom path. The (or ...) encodes the two valid lifts.
  ;; age-peers / blood-kin are belief-pure perceived predicates, so they stay role
  ;; filters (cacheable), gating the bride candidate set directly.
  (role ?bride (unmarried_woman ?bride)
               {?bride age-span ?peer_band}
               (none (blood-kin @self ?bride))
               -{?bride fiancee ?}
               {?bride repute [k exemplary]}
               (or (and {@self class-situation [k middle]}
                        {?bride class-situation [k lower]})
                   (and {@self class-situation [k upper]}
                        {?bride class-situation [k middle]})))

  ;; Only the trait-graded pacing stays live: the exclusivity conditions ARE the
  ;; role/self-gate filters (the cache reconciles at belief-write, so a live
  ;; re-read of the same store cannot differ), and the gender read is the
  ;; maintained {@self gender} self-belief filter above.
  (when (chance (* 0.0833
                   (+ 0.20
                      (* 0.4 (attr @self enthusiasm))
                      (* 0.4 (attr @self openness))))))

  (effects
    (begin-belief {@self fiancee ?bride})
    ; The bride's own engagement belief lands in HER mind (wedding recovers the
    ; groom from the bride's fiancee belief, either side initiating).
    (begin-belief ?bride {?bride fiancee @self})
    ; @self (the groom) discloses his friend-tier profile to the bride (the SAY she
    ; hears and adopts); his own knowledge of her pre-exists from courtship.
    (for-each ?fact-rel (every {@self (disclosure-tier-labels friend) ?})
      (tell-to ?bride (utterable-msg ?fact-rel)))
    ))
