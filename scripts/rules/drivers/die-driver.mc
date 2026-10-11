; ----------------------------------------------------------------------------
; pursue-DIE - a death decided on as an intent (a suicide, intenders/grievance-inward-intender.mc)
; is carried out by proposing DIE until it is done, which ends him and the intent with him.
; ----------------------------------------------------------------------------

(driver {@self intent {@self DIE ?cause}}:?intent
  (effects (maintain-proposal {@self DIE ?cause})))
