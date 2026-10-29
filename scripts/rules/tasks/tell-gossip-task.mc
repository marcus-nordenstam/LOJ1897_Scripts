; ----------------------------------------------------------------------------
; tell-gossip ?friend - @self passes on to a friend each piece of gossip he holds that the friend
; does not know (gossip-for, funcs/conversation.mc), hailing him first unless they are talking.
; Done when there is none left for him; a friend who turns the hail down ends it /fail. Proposed
; by tell-gossip-driver (drivers/tell-gossip-driver.mc).
; ----------------------------------------------------------------------------

(task {@self tell-gossip ?friend}:?tell-gossip
  (tar [k human] @object)
  (lint-waive task-no-preparation)
  (noncompete-set discourse)
  (success-cond (unsubstantial (gossip-for ?friend)))
  (stable-or
    (try
      (when (not (engaged-with ?friend)))
      (effects (maintain-proposal {@self hail ?friend})))
    (try
      (role @self {@self hail ?friend /fail /caused_by ?tell-gossip}:?hail
        (when (hail-turned-down ?friend ?hail))
        (effects (set-outcome ?tell-gossip /fail))))
    (try
      (bind (gossip-for ?friend) ?gossip)
      (when (and (engaged-with ?friend) (substantial ?gossip)))
      (effects (maintain-proposal {@self tell (msg /utterable [/msg-class tidings] ?gossip) ?friend} /quit-trying-on-fail)))))
