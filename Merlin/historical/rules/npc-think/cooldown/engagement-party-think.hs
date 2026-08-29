; ----------------------------------------------------------------------------
; Engagement party. A ceremony that carries a fresh betrothal out from the
; couple to both their social circles - the announcement a Victorian community
; made of an engagement.
;
; Re-fire guard: the fiancee belief started THIS calendar year (a zero
; (year ..)-diff, the job-tenure composition), so the party fires at most once
; per betrothal. The say's per-listener dedup makes any re-announce harmless
; regardless.
;
; Topology: ?bride is enumerated; ?groom is recovered from her fiancee belief.
; Restricting ?bride to women makes each couple enumerate exactly once.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think engagement_party
  (cooldown 1 m)
  (rng-stream marriages)

  ;; SELF-POV (telepathy purge CAT-3): @self the GROOM (belief-pure @self role)
  ;; announces HIS OWN fresh engagement; ?bride is recovered from his OWN fiancee
  ;; belief (no mind peek). The male-gender / spouse / fiancee gates are belief
  ;; filters here; the first-year re-fire guard is a date read that gates the
  ;; fire in (when ...) below.
  (role @self (adult @self)
              {@self gender [k male]}
              (not {@self spouse ?})
              {@self fiancee ?})
  (role ?bride (unmarried_woman ?bride)
               {@self fiancee ?bride}
               {?bride name ?bride_name})

  ;; The fiancee belief must be in its first calendar year - the once-per-betrothal
  ;; re-fire guard; it gates the fire here rather than filtering the role.
  (when (= (- (year (date-now)) (year (any {@self fiancee ?}).start)) 0))

  (effects
    ; Announce the fresh engagement to whoever is co-present (the SAY they hear and
    ; adopt); the wider circle learns via gossip (fiancee is a gossip label).
    (tell (nl-utterable-msg "I am engaged to ?bride_name"))
    ))
