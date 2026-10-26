; ----------------------------------------------------------------------------
; gossip (driver). In a conversation, @self tells the talk the single most gossip-worthy thing
; he knows about a THIRD PARTY that someone in it is not presumed to know: (pick-untold-belief
; /gossip ?talk) picks it, over the (facets gossip_worthy) labels in their (tell-rank) order -
; a witnessed scandal before relationship news - skipping what the listeners are party to or
; were told in his hearing, and never a fact @self is the victim of. The tell is to the
; conversation, so every party hears it, and a listener who hears it files the subject as an
; acquaintance - which is what lets a scandal cascade outward through his network.
;
; Fired MONTHLY: the (chance) is extraversion + assertiveness weighted on top of the
; has-a-friend gate. Picking nothing proposes nothing.
; ----------------------------------------------------------------------------


(driver gossip
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self enthusiasm ?enthusiasm}
              {@self assertiveness ?assertiveness}
              {@self age ?age} {@self friend ?}
    ; The conversation @self is in: he takes part, and it is being held.
    (role ?talk {?talk participant @self} {?talk venue ?}
      (bind (pick-untold-belief /gossip ?talk) ?news)

      (when (and (substantial ?news)
                 (chance (* 0.3
                            (+ 0.5 ?enthusiasm)
                            (+ 0.5 ?assertiveness)))
                 (>= ?age 12)))

      (declare-utility want)

      (effects
        (msg /utterable [] ?news): ?msg
        (maintain-proposal {@self tell ?msg ?talk} /quit-trying-on-fail)))))
