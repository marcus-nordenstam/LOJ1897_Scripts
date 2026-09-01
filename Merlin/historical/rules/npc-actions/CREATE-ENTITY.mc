; ----------------------------------------------------------------------------
; create_entity ?kind - the one general act of bringing an entity of ?kind into
; being out of thin air, born in the space where @self stands (a document, a
; listing, a letter - any prop). Dumb: it only creates. What to do with the fresh
; entity (WRITE on it, ADDRESS it, STACK-PUT it, give it) is the task's job; the
; task binds the new entity by kind at @self afterwards.
; ----------------------------------------------------------------------------

(npc-action {@self CREATE-ENTITY ?kind}
  (duration 5)
  (effects
    (create-entity ?kind (spatial @self space))
    (set-outcome {@self CREATE-ENTITY ?kind} /succ)))
