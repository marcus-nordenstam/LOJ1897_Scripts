; ----------------------------------------------------------------------------
; tell-gossip ?friend - @self passes on to a friend each piece of gossip he holds that the friend
; does not know (gossip-for, funcs/talk.mc), hailing him first unless they are talking.
; Done when there is none left for him; a friend who turns the hail down ends it /fail. Proposed
; by tell-gossip-driver (drivers/tell-gossip-driver.mc).
; ----------------------------------------------------------------------------

(task {@self tell-gossip ?friend}:?tell-gossip
  (belief-timeout 15 min)
  (tar @excl [k human] @object)
  (lint-waive task-no-preparation)
  (category social (scope (talk-between ?friend)))
  (hosts reply enter-talk)
  (success-cond (unsubstantial (gossip-for ?friend)))
  (stable-or
    (try
      (when (and (not (conversing-with ?friend)) (hailable ?friend)))
      (effects (maintain-proposal {@self hail ?friend})))
    (try
      (lod presented)
      (belief ?gossip {@self gossip ?heard}:?gossip
                  (gossip-worthy-for ?heard ?friend)
                  (select (policy first-match))
        (when (conversing-with ?friend))
        (effects (maintain-proposal {@self tell (msg /utterable /tidings [] ?heard) ?friend} /quit-trying-on-fail))))
    (try
      (lod unpresented)
      (belief-list ?gossip-items {@self gossip ?heard}:?gossip
                   (gossip-worthy-for ?heard ?friend)
        (when (conversing-with ?friend))
        (effects
          (maintain-proposal {@self tell (msg /utterable /tidings [] ?gossip-items.target) ?friend}
                             /quit-trying-on-fail))))))
