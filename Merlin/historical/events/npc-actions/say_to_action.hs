
(npc-action {@self say_to ?msg ?audience}
  (duration 0)
  (effects
    (tell-to ?audience ?msg)
    (set-outcome {@self say_to ?msg ?audience} succ)))
