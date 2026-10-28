; ----------------------------------------------------------------------------
; stay-in-conversation (driver) - @self is present in the conversation he takes part in
; (tasks/converse-task.mc) while he talks with someone in it, or while he is left alone in one he
; is not opening, which he holds only to leave it. When it is over is converse's own to judge:
; once nobody has anything left to say it takes his leave, and leaving ends it.
; ----------------------------------------------------------------------------

(driver stay-in-conversation
  (role ?talk {?talk participant @self}
    (when (in-conversation @self ?talk))
    (declare-utility want)
    (stable-or
      (try
        (role ?party {?talk participant ?party}
                     (neq ?party @self)
          (when (and (in-conversation ?party ?talk) (engaged-with ?party)))
          (effects (maintain-proposal {@self converse ?talk}))))
      (try
        (when (and (not (other-party-in ?talk)) (unsubstantial (any {@self hail ?}))))
        (effects (maintain-proposal {@self converse ?talk}))))))
