; ----------------------------------------------------------------------------
; Engagement party. A ceremony that carries a fresh betrothal out from the
; couple to both their social circles - the announcement a Victorian community
; made of an engagement.
;
; Schedule: (annually february) - one month after the (annually january)
; betrothal, so it catches couples betrothed earlier the same year.
;
; Re-fire guard: (= (belief-age ?bride fiancee) 0) - the fiancee belief is in
; its first year. Combined with the annual schedule the party fires at most
; once per betrothal: next february the belief is a year old and the gate
; fails. hold-engagement-party is itself idempotent regardless.
;
; Topology: ?bride is enumerated; ?groom is recovered from her fiancee belief.
; Restricting ?bride to women makes each couple enumerate exactly once.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event engagement_party
  (nl         "?bride and ?groom celebrate their engagement")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY. The (belief-age ?bride fiancee) == 0 gate (whole years) holds while
  ; the betrothal is under a year old, but the wedding occasion (emergent) marries
  ; couples within a month or two, so in practice this fires ~1-2x per betrothal
  ; before the bride is no longer unmarried_woman; hold-engagement-party is
  ; idempotent, so the re-announce is harmless.
  (rng-stream marriages)

  (roles
    (role ?bride (template unmarried_woman)
                 (believes ?self {@self fiancee ?})
                 (= (belief-age ?self fiancee) 0))
    (role ?groom (template unmarried_man)
                 (believes ?bride {@self fiancee ?groom})))

  (effects
    (hold-engagement-party ?bride ?groom)
    (log _engagement_party ?bride)))
