; ----------------------------------------------------------------------------
; flirt-fancy-driver (driver) - in a talk with someone he fancies, @self pays her his compliment
; (tasks/flirt-task.mc). A flirt said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(driver flirt-fancy-driver
  (lod presented)
  (role ?talk {?talk participant @self}:?part -{@self company [k crowded]}
    (role ?partner {@self fancy|desire|crave ?partner}:?fancy
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?partner ?talk)
                 (not (flirted-in ?talk))))
      (declare-utility want (pursuit-utility ?partner (k-flirt-value)))
      (effects (maintain-proposal {@self flirt ?partner ?talk} /caused_by ~[?part ?fancy])))))

; flirt-fancy-direct-driver (driver) - unpresented there is no talk: once a day @self pays someone
; he fancies who is with him his compliment, straight out.
(driver flirt-fancy-direct-driver
  (lod unpresented)
  (cooldown 1 d try-until-succ)
  (role ?partner {@self fancy|desire|crave ?partner}:?fancy -{@self company [k crowded]}
                 (spatial ?partner co-located @self)
                 (select (score (pursuit-utility ?partner (k-flirt-value))) (policy argmax))
    (declare-utility want (pursuit-utility ?partner (k-flirt-value)))
    (effects (maintain-proposal {@self flirt ?partner} /caused_by ?fancy))))
