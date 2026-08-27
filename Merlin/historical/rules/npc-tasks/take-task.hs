; ----------------------------------------------------------------------------
; take ?item - pick the item up into a free hand. The sanity try asserts a hand is free
; (a proposer taking with full hands is an authoring error); the two hand tries propose the
; sided TAKE act (right-handed default: RIGHT_TAKE outbids LEFT_TAKE); the outcome try
; concludes once either hand's take succeeded /caused_by this task.
; ----------------------------------------------------------------------------

(npc-task {@self take ?item}:?take-rel
  (tar @excl object)
  (and
    (try
      (effects (check (or (empty (spatial (spatial @self left_hand) grip))
                          (empty (spatial (spatial @self right_hand) grip))))))
    (try
      (when (empty (spatial (spatial @self left_hand) grip)))
      (utility fallback)
      (effects (check (spatial ?item co-located @self))
               (begin-proposal {@self LEFT_TAKE ?item})))
    (try
      (when (empty (spatial (spatial @self right_hand) grip)))
      (utility (above LEFT_TAKE))
      (effects (check (spatial ?item co-located @self))
               (begin-proposal {@self RIGHT_TAKE ?item})))
    (try
      (when (any {@self /succ LEFT_TAKE|RIGHT_TAKE ?item /caused_by ?take-rel}))
      (effects (set-outcome ?take-rel succ)))))
