; ----------------------------------------------------------------------------
; burial - a priest discharges the burial an unburied death obliges him to
; (reflexes/obligation-burial.mc): once the coroner's month has passed, so that a physician could
; examine the body, he buries the most overdue (tasks/bury-task.mc). A solemn office, it is
; ordered above the church service. An obligation left past its grace strains him.
; ----------------------------------------------------------------------------


(driver bury-obligation
  (role ?corpse {@self obligation {@self bury ?corpse} ?corpse}
                (select (score (months-since-death ?corpse)) (policy argmax))
    (when (>= (months-since-death ?corpse) 1))
    (declare-utility obligation (above attend-church-service))
    (effects (maintain-proposal {@self bury ?corpse}))))
