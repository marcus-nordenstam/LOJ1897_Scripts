
  ; if someone proposes taking when hands are full, that's a rule authoring error
(npc-think take_sanity_check
  (task {@self take ?item})
  (check (or (attr-has-capacity @self left_hand)) 
             (attr-has-capacity @self right_hand)))

(npc-think left_take
  (task {@self take ?item})
  (when (attr-has-capacity @self left_hand))
  (utility 0)
  (effects 
      (check (co-present ?item @self))
      (begin-proposal {@self LEFT_TAKE ?item})))

(npc-think right_take
  (task {@self take ?item})
  (when (attr-has-capacity @self right_hand))
  (utility 10) ; for now assume all NPCs are right-handed; later this should be driven by a handedness check
  (effects 
      (check (co-present ?item @self))
      (begin-proposal {@self RIGHT_TAKE ?item})))

(npc-think take_outcome
  (task {@self take ?item}:?take)
  (when (any {@self /succ LEFT_TAKE|RIGHT_TAKE ?item /caused_by ?take}))
  (effects (set-outcome ?take succ)))
