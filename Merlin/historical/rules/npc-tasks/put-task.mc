; ----------------------------------------------------------------------------
; put ?item ?location - set the held item down. The hand tries propose the sided PUT act
; off whichever hand grips ?item; the outcome try concludes once either put succeeded
; /caused_by this task.
; ----------------------------------------------------------------------------

(npc-task {@self put ?item ?location}:?put-rel
  (tar @excl object)
  (and
    (try
      (when (= (spatial ?item gripped-by) (spatial @self left-hand)))
      (effects (begin-proposal {@self LEFT-PUT ?item ?location})))
    (try
      (when (= (spatial ?item gripped-by) (spatial @self right-hand)))
      (effects (begin-proposal {@self RIGHT-PUT ?item ?location})))
    (try
      (when {@self /succ LEFT-PUT|RIGHT-PUT ?item ?location /caused_by ?put-rel})
      (effects (set-outcome ?put-rel /succ)))))
