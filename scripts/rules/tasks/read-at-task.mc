; ----------------------------------------------------------------------------
; read-at ?venue - a home-leisure reading session at a study/library (proposed by
; household-day for scholarly temperaments). Like rest, it has no sub-steps: the promoted
; task concludes immediately, leaving the ended task belief as the episodic memory.
; ----------------------------------------------------------------------------

(task {@self read-at ?venue}:?read-at
  (tar [k structure|space] @object)
  (try
    (role @self
      (effects (set-outcome ?read-at /succ)))))
