; ----------------------------------------------------------------------------
; rest ?home - an hour off his feet at home, for a strained man (drivers/household-driver.mc).
; ----------------------------------------------------------------------------

(task {@self rest ?home}:?rest
  (construed-act rest-act)
  (tar [k structure|space] @object)
  (running-requirements (inside ?home))
  (sequence
    (stage
      (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))
    (stage
      (effects (set-outcome ?rest /succ)))))
