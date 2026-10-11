; ----------------------------------------------------------------------------
; burial - a priest discharges the obligation an unburied death lays on him
; (reflexes/obliged-burial.mc): once the coroner's month has passed, so that a physician could
; examine the body, he buries the most overdue (tasks/bury-task.mc). A solemn office, it is
; ordered above the church service. An obligation left past its grace strains him.
; ----------------------------------------------------------------------------

(include "../../../macros/tunables.mc")

(driver bury-obliged
  (role ?corpse {@self obliged ?corpse bury}
                (select (score (months-since-death ?corpse)) (policy argmax))
    (when (>= (months-since-death ?corpse) 1))
    (declare-utility obligation (above attend-church-service))
    (effects (maintain-proposal {@self bury ?corpse}))))

(think burial-lapsed
  (cooldown 1 d try-once)
  (cease-after-fire)
  (role ?corpse {@self obliged ?corpse bury}:?obliged
    (when (>= (elapsed /days ?obliged) (burial_grace_days)))
    (effects (mint-pressure-caused [k obligation-strain] @nothing 720 ?obliged))))
