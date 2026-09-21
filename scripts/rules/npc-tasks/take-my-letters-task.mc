; ----------------------------------------------------------------------------
; take-my-letters ?stack - the home post round: read every letter on ?stack that is mine
; and not yet read, and leave the pile as it was found. The whole of the task is the body
; it hands to the generic stack-browse, which does the walking: lift, do this, re-file.
;
; NOTHING IS KEPT. A letter is read where it lies and goes straight back on the pile - the
; pile is the household's correspondence record. That is why the round cannot jam: the only
; hand that touches a doc is the browse's, for the length of one reading.
; ----------------------------------------------------------------------------

(npc-task {@self take-my-letters ?stack}:?take-letters-rel
  (tar @excl [k stack] @object)
  (and
    (try
      (role @self {@self name ?name} 
                  -{@self stack-browse ?stack ? /succ /caused_by ?take-letters-rel}
        (utility errand)
        (effects
          (maintain-proposal
            {@self stack-browse ?stack
              '(if (and (or (and (substantial (tolerate (attr .?item addressee)))
                                 (= (tolerate (attr .?item addressee)) ?name))
                            (nothing (tolerate (attr .?item addressee)))
                            {@self duty-to ? (tolerate (attr .?item addressee-duty))})
                        -{@self READ .?item /succ})
                   (then (maintain-proposal {@self READ .?item})))}))))
    (try
      (role @self {@self stack-browse ?stack ? /succ /caused_by ?take-letters-rel}
        (effects
                 (set-outcome ?take-letters-rel /succ))))))
