; ----------------------------------------------------------------------------
; create_entity ?kind - the one general act of bringing an entity of ?kind into
; being out of thin air, born in the space where @self stands (a document, a
; listing, a letter - any prop). Dumb: it only creates. What to do with the fresh
; entity (WRITE on it, ADDRESS it, STACK-PUT it, give it) is the task's job; the
; task binds the new entity by kind at @self afterwards.
; ----------------------------------------------------------------------------

; ONE AT A TIME. Its whole point is to bring a NEW thing into being, so it is the one
; kind of act that must never be shared: two rungs minting {@self CREATE-ENTITY [k x]}
; are asking for two things, and the proposal merge would give one of them nothing -
; its postlude never runs, so the key it meant to stash the fresh entity under stays
; empty and its stage waits for ever. Proposing a second one while another is live is
; an authoring error and says so out loud.
(npc-action {@self CREATE-ENTITY ?kind}:?ce-rel
  (one-at-a-time)
  (duration 5)
  (effects
    (create-entity ?kind (spatial @self space)): ?made
    (observe ?made): ?known
    (bb-write ?ce-rel created ?known)
    (set-outcome ?ce-rel /succ)))
