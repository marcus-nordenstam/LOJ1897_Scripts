; ----------------------------------------------------------------------------
; write-doc ?doc ?sentence - go to a document and WRITE on it. The write twin of
; read-doc, and the same division of labour: getting there is the TASK's job, penning
; is WRITE's.
;
; A document is written WHERE IT LIES. Co-presence is the room, not the hand - a
; letter made on the desk is written at the desk - so a man who has wandered off
; between making it and penning it walks back, and a form already in his hand has no
; room to walk to.
;
; EVERY task that pens something proposes THIS, never WRITE directly. WRITE asserts
; co-presence with a (check ..), so a task that proposes it from across town does not
; get a wrong letter, it gets an aborted run. That was invisible while every act took
; a minute and nobody could get anywhere in between.
; ----------------------------------------------------------------------------

(npc-task {@self write-doc ?doc ?sentence}:?wd-rel
  (tar [k document] @object)
  (and
    (try
      ; AT HAND is held OR in the room: a form in the hand has no space to walk to.
      (role @self (not (spatial ?doc held-by @self))
                  (not (spatial ?doc co-located @self))
        (utility obligation)
        (effects
          (spatial ?doc space): ?room
          (if (substantial ?room)
              (then (maintain-proposal {@self go ?room}))))))
    (try
      (role @self (or (spatial ?doc held-by @self)
                      (spatial ?doc co-located @self))
                  -{@self WRITE ?doc ? /succ /caused_by ?wd-rel}
        (utility obligation)
        (effects (maintain-proposal {@self WRITE ?doc ?sentence}))))
    ; The sentence is a composed msg, freshly built at each fire, so the done-test
    ; wildcards it and leans on /caused_by to scope the record to THIS activation.
    (try
      (role @self {@self WRITE ?doc ? /succ /caused_by ?wd-rel}
        (effects (set-outcome ?wd-rel /succ))))))
