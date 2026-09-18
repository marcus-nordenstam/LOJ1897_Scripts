; ----------------------------------------------------------------------------
; create_entity ?kind - the one general act of bringing an entity of ?kind into
; being out of thin air, born in the space where @self stands (a document, a
; listing, a letter - any prop). Dumb: it only creates. What to do with the fresh
; entity (WRITE on it, ADDRESS it, STACK-PUT it, give it) is the task's job; the
; task binds the new entity by kind at @self afterwards.
;
; SPAWN WAS THIS ACT UNDER ANOTHER NAME and is gone. They were ONE DEED - a thing comes
; into being at a place - and the merge is a UNION, not a pick (action_unification_plan.md
; 6.2). What SPAWN had that this lacked has come across as (apply-variation ?thing <name>):
; dress a fresh entity as the NAMED variation of its kind and spawn that variation's
; declared children, warning and taking the default on an unknown name. Composed rather
; than bundled, because most things have no variations:
;     (create-entity [k drinking-glass] ?where): ?made
;     (apply-variation ?made pewter-tankard)
; Two of its features are DELETED rather than ported, by ruling: the positional descriptor
; LIST, which was doing qualifier duty by index, and the belief LIST, which [/postlude ..]
; does better - it runs with the PROPOSING activation's bindings live, so the proposer has
; everything it knows in scope. One STILL OWED: its bottom-anchored placement, which put a
; thing's base on a surface rather than its centre. That changes where every existing
; caller's entity lands, so it is its own gated commit.
; ----------------------------------------------------------------------------

; ONE AT A TIME. Its whole point is to bring a NEW thing into being, so it is the one
; kind of act that must never be shared: two rungs minting {@self CREATE-ENTITY [k x]}
; are asking for two things, and the proposal merge would give one of them nothing -
; its postlude never runs, so the key it meant to stash the fresh entity under stays
; empty and its stage waits for ever. Proposing a second one while another is live is
; an authoring error and says so out loud.
(npc-action {@self CREATE-ENTITY ?kind}:?ce-rel
  (one-at-a-time)
  (duration (minutes 5))
  (effects
    (create-entity ?kind (spatial @self space)): ?made
    (observe ?made): ?known
    (bb-write ?ce-rel created ?known)
    (set-outcome ?ce-rel /succ)))
