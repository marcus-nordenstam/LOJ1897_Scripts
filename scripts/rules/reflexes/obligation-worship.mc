; ----------------------------------------------------------------------------
; obligation-worship - attending a church service discharges the Sunday obligation.
; ----------------------------------------------------------------------------

(reflex {@self attend-church-service /succ}
  (effects
    (for-each ?obligation (every {@self obligation {@self attend-church-service} ?})
      (end-belief ?obligation))))
