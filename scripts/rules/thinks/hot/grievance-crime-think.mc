; ----------------------------------------------------------------------------
; pursue-<act> - an intent to answer a grievance with a crime against its focus (the
; intenders of thinks/cooldown/grievance-crime-think.mc) is carried out by that crime's task.
; The task concluding /succ ends the intent, and the intent ending /succ spends the
; grievance that caused it (spent-grievance).
; ----------------------------------------------------------------------------

(driver {@self intent {@self expose ?target}}:?intent
  (role ?partner {?partner isa [k human]}
                 {?target lover|HAVE-SEX-WITH ?partner /ever}
                 -{?target spouse ?partner /ever}
                 -{@self spouse ?partner}
                 -{@self spouse ?target}
                 (select (policy first-match))
    (effects (maintain-proposal {@self expose ?target}))))

(driver {@self intent {@self humiliate ?target}}:?intent
  (effects (maintain-proposal {@self humiliate ?target})))

(driver {@self intent {@self coerce ?target}}:?intent
  (effects (maintain-proposal {@self coerce ?target})))

(driver {@self intent {@self seduce ?target}}:?intent
  (effects (maintain-proposal {@self seduce ?target})))

(driver {@self intent {@self bribe ?target}}:?intent
  (effects (maintain-proposal {@self bribe ?target})))
