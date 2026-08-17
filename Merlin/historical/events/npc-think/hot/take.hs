
  ; if someone proposes taking when hands are full, that's a rule authoring error
(npc-think take_sanity_check
  (task {@self take ?item})
  (check (or (empty (spatial (attr @self left_hand) control))
             (empty (spatial (attr @self right_hand) control)))))

(npc-think left_take
  (task {@self take ?item})
  (when (empty (spatial (attr @self left_hand) control)))
  (utility fallback)
  (effects
      (check (co-present ?item @self))
      (begin-proposal {@self LEFT_TAKE ?item})))

(npc-think right_take
  (task {@self take ?item})
  (when (empty (spatial (attr @self right_hand) control)))
  (utility (above LEFT_TAKE)) ; for now assume all NPCs are right-handed; later this should be driven by a handedness check
  (effects
      (check (co-present ?item @self))
      (begin-proposal {@self RIGHT_TAKE ?item})))

(npc-think take_outcome
  (task {@self take ?item}:?take)
  (when (any {@self /succ LEFT_TAKE|RIGHT_TAKE ?item /caused_by ?take}))
  (effects (set-outcome ?take succ)))
