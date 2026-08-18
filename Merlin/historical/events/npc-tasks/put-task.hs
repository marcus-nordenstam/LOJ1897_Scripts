; ----------------------------------------------------------------------------
; put ?item ?location - set the held item down. The hand tries propose the sided PUT act
; off whichever hand grips ?item; the outcome try concludes once either put succeeded
; /caused_by this task.
; ----------------------------------------------------------------------------

(npc-task {@self put ?item ?location}:?put
  (tar @excl object)
  (and
    (try
      (when (= (spatial ?item gripped_by) (struct @self left_hand)))
      (effects (begin-proposal {@self LEFT_PUT ?item ?location})))
    (try
      (when (= (spatial ?item gripped_by) (struct @self right_hand)))
      (effects (begin-proposal {@self RIGHT_PUT ?item ?location})))
    (try
      (when (any {@self /succ LEFT_PUT|RIGHT_PUT ?item ?location /caused_by ?put}))
      (effects (set-outcome ?put succ)))))
