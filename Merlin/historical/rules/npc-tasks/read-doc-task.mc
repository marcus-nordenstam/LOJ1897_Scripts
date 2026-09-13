; ----------------------------------------------------------------------------
; read-doc ?doc - go to a document and READ it. The one generic "read that paper" task:
; the wage book in the back office, an application form in hand, a deed on a desk. Getting
; there is the task's job (go handles a room in another building as well as the next
; room); reading is READ's. Concluded once THIS activation's READ has succeeded.
; ----------------------------------------------------------------------------

(npc-task {@self read-doc ?doc}:?rd-rel
  (tar document)
  (and
    (try
      ; AT HAND is held OR in the room: a form in the hand has no space to walk to.
      (role @self (not (spatial ?doc held-by @self))
                  (not (spatial ?doc co-located @self)))
      (utility obligation)
      (effects
        (spatial ?doc space): ?room
        (if (substantial ?room)
            (then (maintain-proposal {@self go ?room})))))
    (try
      (role @self (or (spatial ?doc held-by @self)
                      (spatial ?doc co-located @self))
                  -{@self READ ?doc /succ /caused_by ?rd-rel})
      (utility obligation)
      (effects (maintain-proposal {@self READ ?doc})))
    (try
      (role @self {@self READ ?doc /succ /caused_by ?rd-rel})
      (effects (set-outcome ?rd-rel /succ)))))
