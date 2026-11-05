; ----------------------------------------------------------------------------
; maintain-social-presence ?talk - @self's BODY in the conversation ?talk: he stays where he stands
; and faces whom he is talking to. It hosts every line said in the talk, so its stance never
; competes with them, and every act within ?talk - talking with a man in it, or taking one into it
; (scope) - while an act within another talk competes with it. Whether he is in the talk is his part
; in it, {?talk participant @self}, and nothing reads this task for that
; (drivers/stay-in-conversation-driver.mc).
; It is how he leaves: outbid, he says what calls him away (outbids), and withdrawn - the talk
; spent, or he wants it no more - he says goodbye; alone he simply goes. Whatever outbid it waits
; for the line.
; ----------------------------------------------------------------------------

(task {@self maintain-social-presence ?talk}:?maintain-social-presence
  (construed-act social-act)
  (category social (scope ?talk))
  (hosts social reply enter-conversation)
  (tar @excl [k conversation] @object)
  (lint-waive try-rungs-not-exclusive)
  (success-cond (not (in-conversation @self ?talk)))
  (closing
    (sequence
      (stage
        (bind (outbids ?maintain-social-presence) ?outbidder)
        (effects
          (if (and (in-conversation @self ?talk) (other-party-in ?talk))
              (then
                (flip (substantial ?outbidder)
                      (formulaic [] leave_taking excuse ?outbidder)
                      (formulaic [] leave_taking bye)): ?leave-taking
                (maintain-proposal {@self tell ?leave-taking ?talk})))))
      (stage
        (effects
          (leave-conversation ?talk)
          (done-closing ?maintain-social-presence)))))
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
