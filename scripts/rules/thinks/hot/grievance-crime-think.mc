; ----------------------------------------------------------------------------
; pursue-<act> - an intent to answer a grievance with a crime against its focus (the
; intenders of thinks/cooldown/grievance-crime-think.mc) is carried out by that crime's task.
; The task concluding /succ ends the intent, and the intent ending /succ spends the
; grievance that caused it (spent-grievance).
; ----------------------------------------------------------------------------

(driver {@self intent expose ?target}:?intent
  (effects (maintain-proposal {@self expose ?target})))

(driver {@self intent humiliate ?target}:?intent
  (effects (maintain-proposal {@self humiliate ?target})))

(driver {@self intent coerce ?target}:?intent
  (effects (maintain-proposal {@self coerce ?target})))

(driver {@self intent seduce ?target}:?intent
  (effects (maintain-proposal {@self seduce ?target})))

(driver {@self intent bribe ?target}:?intent
  (effects (maintain-proposal {@self bribe ?target})))
