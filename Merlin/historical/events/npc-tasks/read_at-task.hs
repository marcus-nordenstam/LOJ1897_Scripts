; ----------------------------------------------------------------------------
; read_at ?venue - a home-leisure reading session at a study/library (proposed by
; household_day for scholarly temperaments). Like rest, it has no sub-steps: the promoted
; task concludes immediately, leaving the ended task belief as the episodic memory.
; ----------------------------------------------------------------------------

(npc-task {@self read_at ?venue}:?t
  (tar structure|space)
  (try
    (role @self)
    (effects (set-outcome ?t succ))))
