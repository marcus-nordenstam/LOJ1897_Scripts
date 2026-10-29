; ----------------------------------------------------------------------------
; ask-wonder (driver) - the INQUIRY dialogue class: in a talk with a man @self takes to be able to
; tell him what he wonders about, and does not take not to know it, @self asks him
; (tasks/inquire-task.mc). find-out (tasks/find-out-task.mc) brings him to that talk.
; ----------------------------------------------------------------------------

(driver ask-wonder
  (role @self {@self converse ?talk}:?converse {@self wonder ?fact}:?wonder
    (role ?partner {?talk participant ?partner}
                   (neq ?partner @self)
      (when (and (in-conversation @self ?talk)
                 (engaged-with ?partner)
                 (askable ?partner ?fact)))
      (declare-utility want)
      (effects (maintain-proposal {@self inquire ?partner (inquiry-of ?fact)} /caused_by ~[?converse ?wonder])))))
