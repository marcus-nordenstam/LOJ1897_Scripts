; ----------------------------------------------------------------------------
; said - what follows from @self saying a line, whoever wanted it said and whether or not he still
; wants it. The instant his SAY begins the line is logged in the talk it goes into (log-said,
; funcs/talk.mc), as the reply to the line noted for its message, it is recorded in his common
; ground of that talk (record-said), and everyone it reaches is taken to know what it tells
; (mark-told): a listener answers a line from its onset, and what @self says next is decided on
; what this line has told. When the SAY is over the reply note for its message goes.
; ----------------------------------------------------------------------------

(reflex {@self SAY ?line ?audience}:?SAY
  (immediate)
  (effects
    (bind (intended-msg ?SAY) ?msg)
    (record-said ?line (log-said ?SAY ?msg ?audience))
    (mark-told ?SAY ?audience)))

(reflex {@self SAY ?line ?audience /past}:?SAY
  (when (substantial (noted-reply-to (intended-msg ?SAY))))
  (effects (bb-clear-rec @self bbk-reply-to (intended-msg ?SAY))))
