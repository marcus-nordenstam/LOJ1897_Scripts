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

(hsim-event advantageous_match
  (nl         "?groom and ?bride make an advantageous match")
  (kind       _advantageous_match)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY; the per-bride (chance) is scaled by /12 (the *0.0833 wrapper) to hold
  ; the old annual rate.
  (band      afternoon)
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
    (role ?bride (template unmarried_woman)
                 (not (believes ?self {@self fiancee ?}))
                 (= (situation ?self repute) exemplary)
                 ; Additive form so the chance product stays in [0.2, 1.0]
                 ; - keeps the static-bound analyser happy and produces a
                 ; meaningful base rate even for modal-trait brides. The
                 ; full event is still bottlenecked by the very-tight
                 ; exemplary bride + one-class-up groom + age-gap filter,
                 ; so high fire rates aren't expected anyway.
                 (chance (* 0.0833
                            (+ 0.20
                               (* 0.4 (attr ?self enthusiasm))
                               (* 0.4 (attr ?self openness))))))
    ;; A groom one class above the bride. class_situation values are upper /
    ;; middle / lower; the explicit kind literals dodge the ambiguous bare
    ;; atom path. Lower-class brides can lift to middle; middle to upper.
    ;; An upper-class bride uses the ordinary betrothal pathway. The (or ...)
    ;; encodes the two valid class-lifts.
    (role ?groom (template unmarried_man)
                 (not (believes ?self {@self fiancee ?}))
                 (not (= (situation ?self repute) scandalous))
                 (not (= (situation ?self repute) disreputable))
                 (or (and (= (situation ?bride class_situation) lower)
                          (= (situation ?self  class_situation) middle))
                     (and (= (situation ?bride class_situation) middle)
                          (= (situation ?self  class_situation) upper)))
                 (<= (- (years-old ?self) (years-old ?bride))  15)
                 (>= (- (years-old ?self) (years-old ?bride)) -15)
                 ;; No marrying blood kin (see betrothal.hs) - reliable kin
                 ;; cross-pair BITSET.
                 (not (kin ?bride ?groom))))

  ;; Live exclusivity re-check (see betrothal.hs): the un-betrothed role filters
  ;; are alpha-indexed and go stale within the february tick, so without this a
  ;; groom claimed by an earlier exemplary bride this tick could be claimed
  ;; again. The when_gate is evaluated live per firing; the sampler backtracks.
  (when (and (not (believes ?groom {@self fiancee ?}))
             (not (believes ?bride {@self fiancee ?}))))

  (effects
    (begin-belief ?groom fiancee ?bride)
    (begin-belief ?bride fiancee ?groom)
    (believe-about ?groom ?bride)
    (believe-about ?bride ?groom)
    (log _advantageous_match ?groom)))
