; Live crowding ratio: living-npc-count / target. 1.0 at carrying capacity, < 1 when
; sparse, > 1 when crowded. The per-NPC emigration think scales each young
; adult's monthly leave-chance by it, so crowding raises the outflow and a sparse
; parish (immigration territory) sheds almost no one. Replaces the old
; homeostat_emigration "emigrate the oldest N by fiat" world valve.
(define-func population-pressure ()
  (/ /float (living-npc-count) (homeostat_target_population)))
