; ----------------------------------------------------------------------------
; stack-browse ?stack - the GENERIC one-doc-at-a-time stack iteration (the hsim twin of
; isim's stack-browse). It knows NOTHING about why the docs matter: it surfaces ?stack's
; top into hand one at a time, and re-files every doc the consumer marked handled. The
; consumer proposes this browse and, per held pending doc, either KEEPs it (stays in hand,
; leaves the browse) or marks it handled (back to the bottom).
;
; CYCLE DETECTION is browse-cycle-end on ?stack = the first doc buried this round; when it
; resurfaces as the top every original doc has been seen -> concluded. ONE doc in flight:
; browse-inflight names it and is CLEARED the moment it settles, so "nothing in flight" is
; read straight off the slot. It used to be derived by reaching THROUGH the slot at the
; named doc's browse-status - which is only well-formed while a doc IS in flight: with the
; slot empty (before the first lift, and after every conclusion) the inner read answers
; @fail, and a @fail bb host is a loud authoring error that aborts the run.
;
; and (inclusive): the tries are the browse phases (first look / re-look / lift / cycle-end
; / accept-kept / bury-handled), each gated by a distinct stack + hand state.
; ----------------------------------------------------------------------------

(npc-task {@self stack-browse ?stack}:?browse-rel
  (tar stack)
  (and
    (try
      (task-prelude
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then
                  (bb-clear ?stack browse-cycle-end)
                  (bb-clear ?stack browse-inflight)
                  (set-outcome ?browse-rel /succ)))))
    (try
      (when (and (unknown (spatial ?stack top))
                 (bb-none ?stack browse-inflight)))
      (effects
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then
                  (bb-clear ?stack browse-cycle-end)
                  (bb-clear ?stack browse-inflight)
                  (set-outcome ?browse-rel /succ)))))
    (try
      (role ?top (spatial ?stack top)
            (!= ?top (bb-read ?stack browse-cycle-end))
            (bb-none ?stack browse-inflight))
      (effects
        (maintain-proposal {@self STACK-TAKE ?top ?stack}
            [/postlude (bb-write ?top browse-status pending)
                      (bb-write ?stack browse-inflight ?top)])))
    (try
      (role ?top (spatial ?stack top)
            (= ?top (bb-read ?stack browse-cycle-end))
            (bb-none ?stack browse-inflight))
      (effects
        (bb-clear ?stack browse-cycle-end)
        (bb-clear ?stack browse-inflight)
        (set-outcome ?browse-rel /succ)))
    (try
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) kept))
      (effects
        (bb-clear ?doc browse-status)
        (bb-clear ?stack browse-inflight)))
    (try
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) handled))
      (effects
        (maintain-proposal {@self STACK-BURY ?doc ?stack}
            [/postlude (if (not (bb-any ?stack browse-cycle-end))
                          (then (bb-write ?stack browse-cycle-end ?doc)))
                      (bb-clear ?doc browse-status)
                      (bb-clear ?stack browse-inflight)])))))
