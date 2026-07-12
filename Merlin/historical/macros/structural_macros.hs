; ----------------------------------------------------------------------------
; structural_macros.hs - transitive containment predicates, as define-macros.
;
; A mind's perceived structural skeleton is a TREE of ongoing beliefs: a building
; holds {building part room} for each room, each room {room struct_parent building}
; (the @excl reverse), and so on down through furniture and body parts. Both labels
; are hsim-perceptible (common.arc: parts / struct_parent (hsim-percept)), so these
; read the mind's OWN mirror - telepathy-honest, never the env attr.
;
; `part` lists only DIRECT children, so a single (believes) sees one hop. These wrap
; (recursive-believes {..}) - the transitive belief walk - so a grandchild (a chair
; in a room in a building) is reachable. Cache-friendly: as a role filter,
; (recursive-believes ...) materialises the transitive candidate set and reconciles
; coarsely (structural beliefs are written once at perception, then static).
;
; ROLE-FILTER shape: one end MUST be @self or the role candidate (the cache anchors
; there). So (is-part-of ?cand @self) / (is-part-of @self ?cand) cast; a query with a
; bound-var whole (is-part-of ?cand ?home) is a LIVE (when)/(if)/(effects) test, not a
; cacheable role filter.
; ----------------------------------------------------------------------------

; (is-part-of ?x ?whole): is ?x a part of ?whole at ANY depth - directly, or a
; part-of-a-part (a bedroom is-part-of its townhouse; a bed in that bedroom too).
; Walks ?whole's `part` tree downward; true iff ?x is reached. ?x may be a bound
; entity, or a [k <kind>] (does ?whole contain any such thing).
(define-macro is-part-of (?x ?whole)
  (recursive-believes {?whole part ?x}))

; (is-struct-parent-of ?ancestor ?descendant): is ?ancestor a structural parent of
; ?descendant at ANY depth - its direct struct_parent, or a parent-of-a-parent (a
; townhouse is-struct-parent-of a bed two levels down). Walks ?descendant's
; struct_parent chain UPWARD; true iff ?ancestor is reached. The reverse-direction
; dual of is-part-of, over the @excl `struct_parent` label.
(define-macro is-struct-parent-of (?ancestor ?descendant)
  (recursive-believes {?descendant struct_parent ?ancestor}))
