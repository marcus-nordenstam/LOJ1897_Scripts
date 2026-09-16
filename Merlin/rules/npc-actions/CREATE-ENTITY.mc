; ----------------------------------------------------------------------------
; create_entity ?kind - the one general act of bringing an entity of ?kind into
; being out of thin air, born in the space where @self stands (a document, a
; listing, a letter - any prop). Dumb: it only creates. What to do with the fresh
; entity (WRITE on it, ADDRESS it, STACK-PUT it, give it) is the task's job; the
; task binds the new entity by kind at @self afterwards.
; ----------------------------------------------------------------------------

(npc-action {@self CREATE-ENTITY ?kind}:?ce-rel
  (duration 5)
  (effects
    (create-entity ?kind (spatial @self space)): ?made
    (observe ?made): ?known
    (bb-write ?ce-rel created ?known)
    (set-outcome ?ce-rel /succ)))
