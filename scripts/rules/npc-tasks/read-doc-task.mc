; ----------------------------------------------------------------------------
; read-doc ?doc - go to a document and READ it. The one generic "read that paper" task:
; the wage book in the back office, an application form in hand, a deed on a desk. Getting
; there is the task's job (go handles a room in another building as well as the next
; room); reading is READ's. Concluded once THIS activation's READ has succeeded.
; ----------------------------------------------------------------------------

(npc-task {@self read-doc ?doc}:?rd-rel
  (tar document)
  ; THE CONDITION THE TASK RUNS UNDER: he has not read it yet. Stated once here rather
  ; than on the rung that proposes the READ, because it is true of the whole errand -
  ; walking to the room is equally pointless once the page has been read.
  (when -{@self READ ?doc /succ /caused_by ?rd-rel})
  (cease (if (any {@self READ ?doc /succ /caused_by ?rd-rel})
             (then (set-outcome ?rd-rel /succ))))
  (and
    (try
      ; AT HAND is held OR in the room: a form in the hand has no space to walk to.
      (match (not (spatial ?doc held-by @self))
             (not (spatial ?doc co-located @self)))
      (utility obligation)
      (effects
        (spatial ?doc space): ?room
        (if (substantial ?room)
            (then (maintain-proposal {@self go ?room})))))
    (try
      ; The read-yet test is the SPINE's now, so this role states only what is unique to
      ; this rung: the page is within reach.
      (match (or (spatial ?doc held-by @self)
                 (spatial ?doc co-located @self)))
      (utility obligation)
      (effects (maintain-proposal {@self READ ?doc})))))
