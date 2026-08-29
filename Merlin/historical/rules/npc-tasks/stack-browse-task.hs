; ----------------------------------------------------------------------------
; stack_browse ?stack - the GENERIC one-doc-at-a-time stack iteration (the hsim twin of
; isim's stack-browse). It knows NOTHING about why the docs matter: it surfaces ?stack's
; top into hand one at a time, and re-files every doc the consumer marked handled. The
; consumer proposes this browse and, per held pending doc, either KEEPs it (stays in hand,
; leaves the browse) or marks it handled (back to the bottom).
;
; CYCLE DETECTION is browse-cycle-end on ?stack = the first doc buried this round; when it
; resurfaces as the top every original doc has been seen -> concluded. ONE doc in flight
; (browse-inflight); "settled" is DERIVED (the doc's browse-status tag cleared).
;
; and (inclusive): the tries are the browse phases (first look / re-look / lift / cycle-end
; / accept-kept / bury-handled), each gated by a distinct stack + hand state.
; ----------------------------------------------------------------------------

(npc-task {@self stack_browse ?stack}:?browse-rel
  (tar stack)
  (and
    (try
      (task-prelude
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then (debug-print "SBR_EMPTY")
                  (bb-clear ?stack browse-cycle-end)
                  (bb-clear ?stack browse-inflight)
                  (set-outcome ?browse-rel succ)))))
    (try
      (when (and (unknown (spatial ?stack top))
                 (not (bb-private-any (bb-read ?stack browse-inflight) browse-status))))
      (effects
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then (debug-print "SBR_EMPTY")
                  (bb-clear ?stack browse-cycle-end)
                  (bb-clear ?stack browse-inflight)
                  (set-outcome ?browse-rel succ)))))
    (try
      (role ?top (spatial ?stack top)
            (!= ?top (bb-read ?stack browse-cycle-end))
            (not (bb-private-any (bb-read ?stack browse-inflight) browse-status)))
      (effects
        (debug-print "SBR_TAKE doc=?top")
        (maintain-proposal {@self STACK_TAKE ?top ?stack}
            (postlude (bb-write ?top browse-status pending)
                      (bb-write ?stack browse-inflight ?top)))))
    (try
      (role ?top (spatial ?stack top)
            (= ?top (bb-read ?stack browse-cycle-end))
            (not (bb-private-any (bb-read ?stack browse-inflight) browse-status)))
      (effects
        (debug-print "SBR_CYCLED")
        (bb-clear ?stack browse-cycle-end)
        (bb-clear ?stack browse-inflight)
        (set-outcome ?browse-rel succ)))
    (try
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) kept))
      (effects
        (debug-print "SBR_ACCEPT doc=?doc")
        (bb-clear ?doc browse-status)))
    (try
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) handled))
      (effects
        (debug-print "SBR_RETURN doc=?doc")
        (maintain-proposal {@self STACK_BURY ?doc ?stack}
            (postlude (if (not (bb-private-any ?stack browse-cycle-end))
                          (then (bb-write ?stack browse-cycle-end ?doc)))
                      (bb-clear ?doc browse-status)))))))
