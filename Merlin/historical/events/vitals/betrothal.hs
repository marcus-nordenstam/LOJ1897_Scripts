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

(hsim-event betrothal
  (nl         "?groom and ?bride are betrothed")
  (kind       _betrothal)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY, so the per-bride (chance) is /12 of the old annual 0.25 (-> 0.0208)
  ; to hold the annual betrothal rate. Betrothals spread year-round now (the
  ; historical new-year season could be re-added later as a seasonal chance
  ; multiplier). The wedding occasion (already emergent) consumes betrothed couples
  ; monthly; engagement_party announces in the short gap between.
  (band      afternoon)
  (rng-stream marriages)

  (roles
    ;; The (chance 0.25) filter rolls per-bride before any groom search runs,
    ;; so we don't burn the sampler on brides who won't betroth this year.
    ;; Respectability matters: a scandalous OR disreputable bride is socially
    ;; un-marriageable - both are filtered out, the strong-negative the plan
    ;; calls for. The (not (= ...)) form is permissive when the cached belief
    ;; is missing (a young woman appraised before her first december cycle
    ;; reads @fail, not scandalous, and is not excluded). A low chastity
    ;; dimension is catastrophic for a woman - the F3 chastity base is 85 and
    ;; drops by 30 per extra-marital partner, so the 50 floor blocks anyone
    ;; with more than one such past. The chastity filter is permissive when
    ;; the dimension is unread (returns @fail, which falls through < 50 as
    ;; non-numeric -> false comparison, so the (or ...) catches it).
    ;; The market
    ;; reads `repute` / `reputed_chastity` - what has LEAKED - never the
    ;; secret-inclusive self-derived values. A held secret costs nothing
    ;; here; its exposure would - that delta is the blackmail stake.
    (role ?bride (template unmarried_woman)
                 (not (believes ?self {@self fiancee ?}))
                 ;; A lover bond keeps one out of the arranged market ONLY when
                 ;; the lover is a VIABLE match (same station) - such pairs wed
                 ;; via love_match instead, and widows are never handed arranged
                 ;; rematches over a living, marriageable lover. A lover beneath
                 ;; (or above) one's station is NO impediment in the family's
                 ;; eyes: the arranged match proceeds OVER the secret affair -
                 ;; the Madeleine Smith collision (engagement -> jilt attempt ->
                 ;; the letters become blackmail) that the jilt machinery consumes.
                 ;; No lover -> belief-target reads @fail -> the (and ...) is
                 ;; false -> eligible.
                 (not (and (believes ?self {@self lover ?})
                           (= (situation (belief-target ?self lover) class_situation)
                              (situation ?self class_situation))))
                 (not (= (situation ?self repute) scandalous))
                 (not (= (situation ?self repute) disreputable))
                 ;; A fallen woman (divorced for adultery) is shut out of the
                 ;; respectable market absolutely - no decorum or chastity
                 ;; recovery readmits her.
                 (not (believes ?self {@self prototype fallen_woman}))
                 (or (>= (situation ?self reputed_chastity) 0.5)
                     (not (believes ?self {@self reputed_chastity ?})))
                 (chance 0.0208))
    (role ?groom (template unmarried_man)
                 (not (believes ?self {@self fiancee ?}))
                 (not (and (believes ?self {@self lover ?})
                           (= (situation (belief-target ?self lover) class_situation)
                              (situation ?self class_situation))))
                 (not (= (situation ?self repute) scandalous))
                 (not (= (situation ?self repute) disreputable))
                 (= (situation ?self class_situation) (situation ?bride class_situation))
                 (<= (- (years-old ?self) (years-old ?bride))  15)
                 (>= (- (years-old ?self) (years-old ?bride)) -15)
                 ;; No marrying blood kin. A brother is same-class + similar-age,
                 ;; so without this the arranged matcher could betroth siblings.
                 ;; Reliable kin cross-pair BITSET.
                 (not (kin ?bride ?groom))))

  ;; Exclusivity re-check at FIRING time. The role "un-betrothed" filters are
  ;; alpha-indexed (a discriminator bitset built once when the event starts),
  ;; so within a single january tick they go stale: bride #2 still sees a groom
  ;; that bride #1 already betrothed this tick, and one man ends up with several
  ;; fiancees. The when_gate is evaluated LIVE per firing (after prior firings'
  ;; effects commit), so re-checking here catches the within-tick collision;
  ;; the sampler then backtracks to a still-single groom.
  (when (and (not (believes ?groom {@self fiancee ?}))
             (not (believes ?bride {@self fiancee ?}))))

  (effects
    (begin-belief ?groom fiancee ?bride)
    (begin-belief ?bride fiancee ?groom)
    ; Each betrothed learns the other's social profile (identity attrs,
    ; personality, class, birth_date, home, job, immediate kin)
    ; - see hsim::believe_about for the full set.
    (believe-about ?groom ?bride)
    (believe-about ?bride ?groom)
    (log _betrothal ?groom)))
