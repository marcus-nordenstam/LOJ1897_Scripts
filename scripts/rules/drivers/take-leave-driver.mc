; ----------------------------------------------------------------------------
; take-leave (driver) - @self takes his leave of the conversation he is in once nobody in it has
; anything left to say, himself included (said-all, funcs/conversation.mc), and something has been
; said to him in it: the last to run out goes, and his goodbye wakes the rest.
; ----------------------------------------------------------------------------

(driver take-leave-said-all
  (role ?talk {?talk participant @self}:?part
    (role ?speaker {?talk participant ?speaker}
                   {?speaker SAY ? @self /past}:?said
                   (happened-since ?said ?part)
      (when (and (in-conversation @self ?talk) (said-all ?talk)))
      (declare-utility want)
      (effects (maintain-proposal {@self take-leave ?talk} /caused_by ?part)))))
