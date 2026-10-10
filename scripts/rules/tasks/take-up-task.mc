; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the conversation ?partner hailed him into: he gives the
; response its opening calls for, then posts his (conversing ..) naming ?partner, and the
; conversation is open. It is PREPARATION for converse, proposed by engage-hail
; (thinks/hot/answer-hail-think.mc). Until his entry is posted the hail still stands, so a man
; who finds something keener first declines it instead (decline-hail).
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (tar @excl [k human] @object)
  (preparatory)
  (sequence
    (role @self {?partner SAY (formulaic ? opening ?greeting) @self /past}
      (stage
        (effects (maintain-proposal {@self tell (formulaic [] response ?greeting) ?partner})))
      (stage
        (effects
          (bb-public-write @self conversing ?partner)
          (set-outcome ?take-up /succ))))))
