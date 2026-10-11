; ----------------------------------------------------------------------------
; PILE-SPLIT-LEFT / PILE-SPLIT-RIGHT ?from ?count - count ?count units off a pile within reach
; into a new pile of the same content, held in the left / right hand. ?count may be 0: an
; empty pile to start one with.
; ----------------------------------------------------------------------------

(action {@self PILE-SPLIT-LEFT ?from ?count}:?PILE-SPLIT-LEFT
  (motor left-hand legs)
  (duration (seconds 1 min))
  (effects
    (split-pile-into-hand ?from ?count (spatial @self left-hand /env))
    (set-outcome ?PILE-SPLIT-LEFT /succ)))

(action {@self PILE-SPLIT-RIGHT ?from ?count}:?PILE-SPLIT-RIGHT
  (motor right-hand legs)
  (duration (seconds 1 min))
  (effects
    (split-pile-into-hand ?from ?count (spatial @self right-hand /env))
    (set-outcome ?PILE-SPLIT-RIGHT /succ)))
