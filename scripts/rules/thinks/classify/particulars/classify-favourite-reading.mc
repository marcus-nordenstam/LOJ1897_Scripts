; ----------------------------------------------------------------------------
; classify-favourite-reading - the kind of book @self holds the warmest, once one is warm enough
; to be liked; none until then.
; ----------------------------------------------------------------------------

(think classify-favourite-reading
  (role @self {@self like|adore|dislike|detest [k sermon-book|romance-novel|adventure-novel|detective-novel|scientific-romance|penny-dreadful|poetry-book|almanac]}
    (effects
      (mint-argmax {@self favourite} (favourite-warmth-min) @nothing
        [k sermon-book]        (stance [k sermon-book] warmth)
        [k romance-novel]      (stance [k romance-novel] warmth)
        [k adventure-novel]    (stance [k adventure-novel] warmth)
        [k detective-novel]    (stance [k detective-novel] warmth)
        [k scientific-romance] (stance [k scientific-romance] warmth)
        [k penny-dreadful]     (stance [k penny-dreadful] warmth)
        [k poetry-book]        (stance [k poetry-book] warmth)
        [k almanac]            (stance [k almanac] warmth)))))
