; ----------------------------------------------------------------------------
; WEAR - ?article goes onto ?part and stays there.
;
; PORTED from the C++ handler (action_unification_plan.md). The env model is the `wear` attr the hand
; and finger archetypes carry, and the grip that held the article up to be put on is
; released by the same act - "what a body part wears, and what releases its grip to
; let it be worn" were both left to the corpus, and this is the corpus.
; ----------------------------------------------------------------------------


(npc-action {@self WEAR ?article ?part}:?wear
  (motor right-hand legs)
  (obs)
  (tar @excl)
  (duration 0.6)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))

  (init
    (check (substantial ?part)))

  (effects
    (check (spatial ?article co-located @self /env))
    (set-attr ?part wear ?article)
    ; Worn is not held: the hand that offered it up lets go, and the article rides the
    ; part from here. release-grip files it into @self's own space, which is where a
    ; worn thing is.
    (release-grip ?article (spatial @self space /env))
    (if (presented-lod)
        (then (attach-to-socket ?article ?part @nothing)))
    (set-outcome ?wear /succ)))
