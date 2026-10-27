; ----------------------------------------------------------------------------
; return-tidings (driver) - the REACTIVE driver of friend-talk: a party of @self's conversation told
; him tidings, and he has tidings of his own for that one, so he answers in kind
; (tasks/friend-talk-task.mc). His friend-talk is caused by the presence it runs under and by the
; line it answers. The proactive driver is seek-company (drivers/seek-company-driver.mc).
; ----------------------------------------------------------------------------

(driver return-tidings
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY (msg ~[/msg-class tidings] ?..) @self /past}:?line
                   -{@self friend-talk ? ?speaker /succ /caused_by ?line}
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?speaker ?talk)
                 (or (substantial (friend-talk-line ?talk ?speaker))
                     (friend-awaits-reply ?talk ?speaker))))
      (declare-utility want)
      (effects (maintain-proposal {@self friend-talk ?talk ?speaker} /caused_by ~[?converse ?line])))))
