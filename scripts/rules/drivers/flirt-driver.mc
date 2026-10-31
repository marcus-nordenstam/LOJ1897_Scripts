; ----------------------------------------------------------------------------
; flirt-fancy-driver (driver) - in a talk with someone he fancies, @self pays her his compliment
; (tasks/flirt-task.mc). A flirt said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(driver flirt-fancy-driver
  (role @self {@self converse ?talk}:?converse -{@self company [k crowded]}
    (role ?partner {@self fancy|desire|crave ?partner}:?fancy
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?partner ?talk)
                 (not (flirted-in ?talk))))
      (declare-utility want (pursuit-worth ?partner (k-flirt-value)))
      (effects (maintain-proposal {@self flirt ?talk ?partner} /caused_by ~[?converse ?fancy])))))
