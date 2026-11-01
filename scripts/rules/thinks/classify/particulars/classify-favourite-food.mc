; ----------------------------------------------------------------------------
; classify-favourite-food - the dish @self holds the warmest, once one is warm enough to be liked;
; none until then.
; ----------------------------------------------------------------------------

(think classify-favourite-food
  (role @self {@self like|adore|dislike|detest [k roast-beef|mutton|pie|fish|oyster|curry|pickles|pudding|bread|cheese-food]}
    (effects
      (mint-argmax {@self favourite} (favourite-warmth-min) @nothing
        [k roast-beef]   (stance [k roast-beef] warmth)
        [k mutton]       (stance [k mutton] warmth)
        [k pie]          (stance [k pie] warmth)
        [k fish]         (stance [k fish] warmth)
        [k oyster]       (stance [k oyster] warmth)
        [k curry]        (stance [k curry] warmth)
        [k pickles]      (stance [k pickles] warmth)
        [k pudding]      (stance [k pudding] warmth)
        [k bread]        (stance [k bread] warmth)
        [k cheese-food]  (stance [k cheese-food] warmth)))))
