; ----------------------------------------------------------------------------
; take ?item - pick the item up into a free hand. The sanity try asserts a hand is free
; (a proposer taking with full hands is an authoring error); the two hand tries propose the
; sided TAKE act (right-handed default: RIGHT-TAKE outbids LEFT-TAKE); the outcome try
; concludes once either hand's take succeeded /caused_by this task.
; ----------------------------------------------------------------------------

(npc-task {@self take ?item}:?take-rel
  (tar @excl object)
  (and
    (try
      (effects (check (or (empty (spatial (spatial @self left-hand) grip))
                          (empty (spatial (spatial @self right-hand) grip))))))
    (try
      (when (empty (spatial (spatial @self left-hand) grip)))
      (utility fallback)
      (effects (check (spatial ?item co-located @self))
               (begin-proposal {@self LEFT-TAKE ?item})))
    (try
      (when (empty (spatial (spatial @self right-hand) grip)))
      (utility (above LEFT-TAKE))
      (effects (check (spatial ?item co-located @self))
               (begin-proposal {@self RIGHT-TAKE ?item})))
    (try
      (when {@self /succ LEFT-TAKE|RIGHT-TAKE ?item /caused_by ?take-rel})
      (effects (set-outcome ?take-rel /succ)))))
