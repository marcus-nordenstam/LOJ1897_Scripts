; ----------------------------------------------------------------------------
; burial - a priest discharges the burial an unburied death obliges him to
; (reflexes/obligation-burial.mc): once the coroner's month has passed, so that a physician could
; examine the body, he buries the most overdue (tasks/bury-task.mc). A solemn office, it is
; ordered above the church service. An obligation left past its grace strains him.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(think burial-lapsed
  (role ?corpse {@self obligation {@self bury ?corpse} ?corpse}:?obligation
    (when (>= (elapsed /days ?obligation) (burial_grace_days)))
    (effects (mint-pressure-caused [k obligation-strain] @nothing 720.0 ?obligation))))
