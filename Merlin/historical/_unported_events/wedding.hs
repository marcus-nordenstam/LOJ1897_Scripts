; ----------------------------------------------------------------------------
; Wedding. Consumes the betrothed couples that betrothal.hse produced: a woman
; holding an ongoing {@self fiancee ?groom} belief marries that groom. The
; fiancee bond is ended and the {spouse} bond asserted; hold-wedding then
; carries the marriage to both guest circles.
;
; OCCASION-FIRED (Section 4.11): no (schedule). The wedding is fired by the venue
; pool's occasion system (realize_occasions): produce_occasions stages a wedding
; occasion at the bride's parish church for each still-betrothed couple on the
; month's first active day, draws the couple (+ guests) there, and fires THIS
; event with ?bride and ?groom both PRESET - so the gender-correct couple is bound
; directly (not an arbitrary church-goer) and only the (when) gate + effects run.
; It is suppressed from the DES and the per-NPC pass (marked place-lane in
; run_tick) and carries no afford entry, so resolve_affordances never offers it.
;
; Topology: ?bride and ?groom are both supplied by the occasion (bride = the
; woman, groom = her fiance); the (when) gate below re-confirms the betrothal at
; fire time (defence against within-tick staleness).
;
; This supersedes the propagation the old marriage.hse performed: it carries
; the {spouse} beliefs, the believe-about mirror (already done at betrothal),
; the in-law wiring and the family minting forward.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event wedding
  (nl         "?groom marries ?bride")
  (kind       _wedding)
  (band      morning)
  (rng-stream marriages)

  (roles
    (role ?bride (template unmarried_woman)
                 (believes ?self {@self fiancee ?}))
    (role ?groom (template unmarried_man)
                 (believes ?bride {@self fiancee ?groom})))

  ;; Both roles are preset by the occasion (their role filters are skipped on
  ;; preset), so re-confirm the betrothal still stands and neither has married
  ;; since the couple list was built - else drop this firing cleanly.
  (when (and (believes ?bride {@self fiancee ?groom})
             (not (believes ?bride {@self spouse ?}))
             (not (believes ?groom {@self spouse ?}))))

  (effects
    ; End the betrothal, then assert the marriage. fiancee and spouse are
    ; distinct @excl labels, so the order is cosmetic.
    (end-belief   ?bride fiancee ?groom)
    (end-belief   ?groom fiancee ?bride)
    (begin-belief ?groom spouse ?bride)
    (begin-belief ?bride spouse ?groom)
    ; Carry the marriage to the couple's guest circles - each guest learns
    ; {groom spouse bride} and a refreshed profile of both newlyweds.
    (hold-wedding ?groom ?bride)
    ; Wires *_in_law and step* beliefs on both sides - see
    ; Src/Lib/hsim/hsim_belief_propagation.cc :: propagate_in_laws_at_marriage.
    (propagate-in-laws ?groom ?bride)
    ; Recall-or-mint each spouse's per-mind `family` mental object and enrol
    ; the partner (plus prior children) - see propagate_family_at_marriage.
    (propagate-family ?groom ?bride)
    (log _wedding ?groom)))
