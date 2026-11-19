; ----------------------------------------------------------------------------
; respond-driver (driver) - THE reactive driver of talk: a line a participant of @self's talk said
; to him, whose record in the talk's log says he owes it a reply and that it
; waits on nothing (bbk-line, boards/talk.mc), he responds to (tasks/respond-task.mc), one at a
; time: the oldest such line first. The debt is the record's and nothing else's: it is paid in the
; talk the line was said in, and goes with it. An opening he took up or turned down was answered
; by that (the hail answers in drivers/answer-hail-driver.mc are for a hailer outside the talk he
; is in).
; ----------------------------------------------------------------------------

(driver respond-driver
  (role ?talk {?talk participant @self}
    (bind (owed-line ?talk) ?line)
    (bind (line-speaker ?line) ?speaker)
    (when (and (is-belief ?line) (in-talk @self ?talk)))
    (declare-utility obligation)
    (effects (maintain-proposal {@self respond ?speaker ?line}))))
