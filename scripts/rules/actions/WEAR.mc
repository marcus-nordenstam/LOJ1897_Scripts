; ----------------------------------------------------------------------------
; WEAR - ?article goes onto ?part and stays there.
;
; PORTED from the C++ handler (action_unification_plan.md). The env model is the `wear` attr the hand
; and finger archetypes carry, and the grip that held the article up to be put on is
; released by the same act - "what a body part wears, and what releases its grip to
; let it be worn" were both left to the corpus, and this is the corpus.
; ----------------------------------------------------------------------------


(action {@self WEAR ?article ?part}:?WEAR
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
    ; part from here. It is set on the floor spot nearest him in his own space, which is
    ; where a worn thing is filed.
    (release-grip ?article (find-spot ?article [/on_floor_of (spatial @self space /env)] [/near @self]))
    (if (presented-lod)
        (then (attach-to-socket ?article ?part @nothing)))
    (set-outcome ?WEAR /succ)))
