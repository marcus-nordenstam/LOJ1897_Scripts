; ----------------------------------------------------------------------------
; maintain-social-presence ?talk - @self's BODY in the conversation ?talk: he stays where he stands
; and faces whom he is talking to. It hosts every line said in the talk, so its stance never
; competes with them. Whether he is in the talk is his part in it, {?talk participant @self}, and
; nothing reads this task for that (drivers/stay-in-conversation-driver.mc).
; ----------------------------------------------------------------------------

(task {@self maintain-social-presence ?talk}:?maintain-social-presence
  (construed-act social-act)
  (category social)
  (hosts social reply)
  (tar @excl [k conversation] @object)
  (lint-waive try-rungs-not-exclusive)
  (success-cond (not (in-conversation @self ?talk)))
  (and
    (try
      (lint-waive cacheable-read-in-when)
      (declare-utility fallback)
      (when (in-conversation @self ?talk))
      (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))
    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (substantial ?focus))
      (effects (maintain-proposal {@self LOOK-AT ?focus})))
    (try
      (lint-waive cacheable-read-in-when)
      (bind (focus-of ?talk) ?focus)
      (when (and (substantial ?focus) (not (is-facing ?focus))))
      (effects (maintain-proposal {@self TURN-TO ?focus})))))
