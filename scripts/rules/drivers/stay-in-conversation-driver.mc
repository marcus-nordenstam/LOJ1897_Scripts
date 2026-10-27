; ----------------------------------------------------------------------------
; stay-in-conversation (driver) - @self stays present in the conversation he is talking in while
; anyone in it still has something to say (said-all, funcs/conversation.mc): he runs out of lines
; before the others do and listens; the last to run out takes his leave
; (drivers/take-leave-driver.mc).
; ----------------------------------------------------------------------------

(driver stay-in-conversation
  (role ?talk {?talk participant @self}
    (role ?party {?talk participant ?party}
                 (neq ?party @self)
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?party ?talk)
                 (engaged-with ?party)
                 (not (said-all ?talk))))
      (declare-utility want)
      (effects (maintain-proposal {@self converse ?talk})))))

; Left alone in a conversation he is not opening: he holds it only to leave it, which releases it.
(driver left-alone-in-conversation
  (role ?talk {?talk participant @self}
    (when (and (in-conversation @self ?talk)
               (not (other-party-in ?talk))
               (unsubstantial (any {@self hail ?}))))
    (declare-utility want)
    (effects (maintain-proposal {@self converse ?talk}))))
