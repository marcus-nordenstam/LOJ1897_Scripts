; ----------------------------------------------------------------------------
; flirt-fancy-driver (driver) - in a talk with someone he fancies, @self pays her his compliment
; (tasks/flirt-task.mc). A flirt said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(driver flirt-fancy-driver
  (role ?talk {?talk participant @self} -{@self company [k crowded]}
    (role ?partner {@self fancy|desire|crave ?partner}:?fancy
      (when (and (in-talk @self ?talk)
                 (in-talk ?partner ?talk)
                 (not (flirted-in ?talk))))
      (declare-utility want (pursuit-utility ?partner (k-flirt-value)))
      (effects (maintain-proposal {@self flirt ?partner ?talk} /caused_by ?fancy)))))
