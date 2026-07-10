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

(npc-think engagement_party
  (long-term-think)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
  ; MONTHLY. The (belief-age ?bride fiancee) == 0 gate (whole years) holds while
  ; the betrothal is under a year old, but the wedding occasion (emergent) marries
  ; couples within a month or two, so in practice this fires ~1-2x per betrothal
  ; before the bride is no longer unmarried_woman; hold-engagement-party is
  ; idempotent, so the re-announce is harmless.
  (rng-stream marriages)

  ;; SELF-POV (telepathy purge CAT-3): @self the GROOM (belief-pure @self role)
  ;; announces HIS OWN fresh engagement; ?bride is recovered from his OWN fiancee
  ;; belief (no mind peek). The male-gender gate and the first-year belief-age
  ;; re-fire guard are non-belief filters - moved to (when ...) below.
  (role @self (adult @self)
              (not (believes {@self spouse ?}))
              (believes {@self fiancee ?}))
  (role ?bride (unmarried_woman ?bride)
               (believes {@self fiancee ?bride}))

  ;; Moved from the @self role (non-belief filters): groom must be male, and the
  ;; fiancee belief must be in its first year (the once-per-betrothal re-fire guard).
  (when (and (= (attr @self gender) [k male])
             (= (belief-age @self fiancee) 0)))

  (effects
    (hold-engagement-party ?bride @self)
    ))
