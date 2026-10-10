; ----------------------------------------------------------------------------
; PILE-SPLIT ?from ?count - count ?count units off a pile within reach into a new pile of
; the same content, held in the right hand. ?count may be 0: an empty pile to start one
; with. The new pile is named on the act's bb as `created`, for the proposer's postlude.
; ----------------------------------------------------------------------------

(action {@self PILE-SPLIT ?from ?count}:?PILE-SPLIT
  (motor right-hand legs)
  (duration (seconds 1 min))
  (effects
    (spatial @self right-hand /env): ?hand
    (check (spatial @self can-reach ?from /env))
    (check (empty (spatial ?hand grip /env)))
    (check (>= (attr ?from count) ?count))
    (create-entity [k pile] (spatial @self space /env)): ?split
    (set-attr ?split content-kind (attr ?from content-kind))
    (set-attr ?split count 0)
    (pile-add ?from (- 0 ?count))
    (pile-add ?split ?count)
    (grip-into-hand ?split ?hand): ?known
    (bb-write ?PILE-SPLIT created ?known)
    (set-outcome ?PILE-SPLIT /succ)))
