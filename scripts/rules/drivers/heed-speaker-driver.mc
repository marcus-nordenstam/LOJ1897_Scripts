; ----------------------------------------------------------------------------
; heed-speaker-driver (driver). A man another is speaking to (another holds the turn of @self or
; of his conversation, spoken-to in funcs/conversation.mc) stays where he is until the line is said or
; the speaker lets him go: the speaker does the closing in, never the man spoken to, so two men
; never walk round each other to talk. The decision is made by the speaking, so it is unbeatable.
; ----------------------------------------------------------------------------

(driver heed-speaker-driver
  (belief {@self isa [k human]}
    (when (spoken-to))
    (declare-utility unbeatable)
    (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)}))))
