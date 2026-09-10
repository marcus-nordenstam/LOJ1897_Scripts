; ----------------------------------------------------------------------------
; object-identity - recognising that a thing @self only IMAGINED is a thing he has now
; perceived. The imagined half comes from paper and hearsay: a man read of on an
; application, a workplace named on a notice, a room a notice sent him to.
;
; The engine keeps the two halves it can own: WHICH imagined objects are up for
; reconciliation ((is-reconcilable ?x) - the participants of a running act, plus whatever
; a rule arms with (set-reconcilable ?x @true)), and the FUSION itself ((reconcile ?imag
; ?real): the imagined object's beliefs rewired onto the real one, the imagined one
; discarded). What counts as "the same thing" is content, and lives here.
;
; TWO criteria, and they are kind-general on purpose. A NAME identifies whatever bears
; one - a person today, a ship or a horse the day the world has them - so the rule binds
; the kind off the imagined side rather than naming one. An ADDRESS identifies a place,
; and since every interior space carries one too, the same rule fuses the room a notice
; sent him to with the room he walks into.
;
; The kind test is NOT optional. (reconcile ..) fuses what it is handed without
; re-checking, so without (is-a ?real ?k) a ship named Edith would be folded into a woman
; named Edith.
;
; Both are cached, wake-driven role filters: the perception write of the real thing's
; name / address belief (meeting the man, walking past the sign) re-tests membership and
; arms the rule, and the object-mood hook re-tests it when the reconcilable flag flips.
; Nothing polls.
; ----------------------------------------------------------------------------

(npc-think identity_by_name
  (role ?imag (is-reconcilable ?imag) {?imag name ?n})
  (role ?real (observed ?real) {?real name ?n})
  (when (and (kind ?imag): ?k
             (is-a ?real ?k)))
  (effects
    (reconcile ?imag ?real)))

(npc-think identity_by_address
  (role ?imag (is-reconcilable ?imag) {?imag address ?a})
  (role ?real (observed ?real) {?real address ?a})
  (when (and (kind ?imag): ?k
             (is-a ?real ?k)))
  (effects
    (reconcile ?imag ?real)))
