; ----------------------------------------------------------------------------
; receive-given-driver - a man giving @self something posts `receive-from` himself on @self's
; public bb for as long as he is giving (tasks/give-task.mc); @self receives from him.
; ----------------------------------------------------------------------------

(driver receive-given-driver
  (when (bb-public-any @self receive-from))
  (declare-utility want)
  (effects
    (bind (bb-public-read @self receive-from) ?giver)
    (maintain-proposal {@self receive ?giver})))
