
(npc-think left_put
  (task {@self put ?item ?location})
  (when (= (spatial ?item controlled_by) (struct @self left_hand)))
  (effects (begin-proposal {@self LEFT_PUT ?item ?location})))

(npc-think right_put
  (task {@self put ?item ?location})
  (when (= (spatial ?item controlled_by) (struct @self right_hand)))
  (effects (begin-proposal {@self RIGHT_PUT ?item ?location})))

(npc-think put_outcome
  (task {@self put ?item ?location}:?put)
  (when (any {@self /succ LEFT_PUT|RIGHT_PUT ?item ?location /caused_by ?put}))
  (effects (set-outcome ?put succ)))
