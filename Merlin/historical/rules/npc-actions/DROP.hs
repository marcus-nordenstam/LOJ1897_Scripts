; ----------------------------------------------------------------------------
; drop - the one dumb act of setting a held thing down where @self stands: the
; grip empties and the thing lands in @self's current space. The inverse of take.
; General - any prop (a read letter to be left behind, a tool set aside). Where the
; thing goes and why is the task's decision; this act just lets go, here.
; ----------------------------------------------------------------------------

(npc-action {@self DROP ?thing}
  (duration 1)
  (effects
    (spatial-write ?thing location (spatial @self space /env))
    (set-outcome {@self DROP ?thing} /succ)))
