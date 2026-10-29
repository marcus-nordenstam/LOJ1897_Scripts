; ----------------------------------------------------------------------------
; heed-speaker (driver). A man another has taken on to speak to (his address mark on @self's
; board, claim-addressees in funcs/conversation.mc) stays where he is until the line is said or
; the speaker lets him go: the speaker does the closing in, never the man spoken to, so two men
; never walk round each other to talk. The decision is made by the speaking, so it is unbeatable.
; ----------------------------------------------------------------------------

(driver heed-speaker
  (role @self {@self isa [k human]}
    (when (addressed-by-another @self))
    (declare-utility unbeatable)
    (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)}))))
