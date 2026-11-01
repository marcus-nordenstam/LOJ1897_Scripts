; ----------------------------------------------------------------------------
; classify-favourite-drink - the drink @self holds the warmest, once one is warm enough to be
; liked; none until then.
; ----------------------------------------------------------------------------

(think classify-favourite-drink
  (role @self {@self like|adore|dislike|detest [k beer|porter|gin|whisky|claret|tea-drink|coffee|lemonade]}
    (effects
      (mint-argmax {@self favourite} (favourite-warmth-min) @nothing
        [k beer]      (stance [k beer] warmth)
        [k porter]    (stance [k porter] warmth)
        [k gin]       (stance [k gin] warmth)
        [k whisky]    (stance [k whisky] warmth)
        [k claret]    (stance [k claret] warmth)
        [k tea-drink] (stance [k tea-drink] warmth)
        [k coffee]    (stance [k coffee] warmth)
        [k lemonade]  (stance [k lemonade] warmth)))))
