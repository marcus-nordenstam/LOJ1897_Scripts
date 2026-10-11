; --- keep the men we wrote to in sight ---------------------------------------
; A man the officer offered a post to exists in his mind as a name on paper - realis,
; ungrounded. The day he walks in perception mints a second object, and the two fuse only
; if the paper one is in the RECONCILE set at that moment. The pipeline arms an object only
; while an act involving it runs, so the arming must be renewed for as long as the offer is
; outstanding: every offer-letter record whose man is not yet on any book.
(think rearm-offerees
  (aspect labour)
  (cooldown 1 d try-once)
  (role @self {@self duty-to ?org recruit-staff}
    (role ?p [k human] {? offered-to ?p}
                       -{?p job ?}
      (effects (set-reconcilable ?p @true)))))
