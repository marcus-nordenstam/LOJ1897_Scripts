; ----------------------------------------------------------------------------
; remove-ad ?org ?job - take the notice for ONE post down, once that post is filled.
; The exact twin of post-ad: that task minted {?org display-ad ?job}, this one ends it,
; and between them the belief says exactly what the board shows.
;
; The notice is found the way it was posted - at a church, among the job-descriptions
; @self penned ({@self WRITE ?ad ? /succ} is the record of his own hand, and it is what
; tells his notice from another firm's). DESTROY-ENTITY takes it off the board, and the
; paper being gone is what ends the standing state: the belief is never retired ahead of
; the thing it describes.
;
; This replaces the old take_down_filled think rung, which had to live outside the task
; because recruit-staff had already concluded by the time the book filled. The daily
; recruit-staff round no longer concludes on a full book, so the take-down is a rung of
; it like every other piece of the officer's order of business.
; ----------------------------------------------------------------------------

(npc-task {@self remove-ad ?org ?job}:?rad-rel
  (tar org)
  (aux job)
  (and
    (try
      (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))
      (when (not (spatial @self building ?board)))
      (effects (maintain-proposal {@self enter ?board})))
    ; ?ad ENUMERATED: an officer can have several notices of his own on one board, and a
    ; single bind would take the first and only ever test THAT one.
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            {@self WRITE ?ad ? /succ})
      (effects (maintain-proposal {@self DESTROY-ENTITY ?ad})))
    (try
      (when {@self DESTROY-ENTITY ? /succ /caused_by ?rad-rel})
      (effects
               (end-belief {?org display-ad ?job})
               (set-outcome ?rad-rel /succ)))))
