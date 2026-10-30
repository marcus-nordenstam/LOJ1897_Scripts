; ----------------------------------------------------------------------------
; stay-in-conversation-driver (driver) - @self is present in the conversation he takes part in
; (tasks/converse-task.mc) while he talks with someone in it, or while he is left alone in one,
; which he holds only to leave it. When it is over is converse's own to judge:
; once nobody has anything left to say it takes his leave, and leaving ends it.
; ----------------------------------------------------------------------------

(driver stay-in-conversation-driver
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
        (when (not (other-party-in ?talk)))
        (effects (maintain-proposal {@self converse ?talk}))))))

; A crowded man takes his leave of a talk he is held in only by his own want of it.
(driver crowded-leave-driver
  (role @self {@self company [k crowded]}
    (role ?talk {?talk participant @self} {@self converse ?talk}:?converse
      (when (and (in-conversation @self ?talk)
                 (other-party-in ?talk)
                 (< (utility ?converse) (utility errand 0.0))))
      (declare-utility want)
      (effects (maintain-proposal {@self take-leave ?talk})))))
