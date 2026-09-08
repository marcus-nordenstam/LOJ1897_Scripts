; ----------------------------------------------------------------------------
; remove-ad ?org ?job - take the notice for ONE post down, once that post is filled.
; The exact twin of post-ad: that task minted {?org display-ad ?job}, this one ends it,
; and between them the belief says exactly what the board shows.
;
; The notice is found the way it was posted - at a church, among the job-descriptions
; @self penned ({@self WRITE ?ad ? /succ} is the record of his own hand, and it is what
; tells his notice from another firm's). DESTROY-ENTITY takes it off the board, and the
; paper being gone is what ends the standing state: the belief is never retired ahead of
; the thing it describes. One sequence: go to a board, destroy the notice found there,
; end the standing belief.
; ----------------------------------------------------------------------------

(npc-task {@self remove-ad ?org ?job}:?rad-rel
  (tar org)
  (aux job)
  (sequence
    (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))

    (stage
      (effects
        (if (not (spatial @self building ?board))
            (then (maintain-proposal {@self enter ?board})))))

    (stage
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            {@self WRITE ?ad ? /succ})
      (effects (maintain-proposal {@self DESTROY-ENTITY ?ad})))

    (stage
      (effects
        (end-belief {?org display-ad ?job})
        (set-outcome ?rad-rel /succ)))))
