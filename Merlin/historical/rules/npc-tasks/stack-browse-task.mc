; ----------------------------------------------------------------------------
; stack-browse ?stack - the GENERIC one-doc-at-a-time stack iteration (the hsim twin of
; isim's stack-browse). It knows NOTHING about why the docs matter: it surfaces ?stack's
; top into hand one at a time, and re-files every doc the consumer marked handled. The
; consumer proposes this browse and, per lifted doc, writes its VERDICT on the running
; browse: kept (stays in hand, leaves the browse) or handled (back to the bottom).
;
; All browse state is tagged on the running browse act ?browse-rel and dies with it:
;   inflight  - the ONE doc lifted and awaiting the consumer's verdict; cleared when it settles
;   verdict   - the consumer's kept / handled for the doc in flight
;   cycle-end - the first doc buried this round; when it resurfaces as the top every original
;               doc has been seen -> concluded.
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
            (then (set-outcome ?browse-rel /succ)))))
    (try
      (role @self (bb-none ?browse-rel inflight))
      (when (unknown (spatial ?stack top)))
      (effects
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then (set-outcome ?browse-rel /succ)))))
    (try
      (role ?top (spatial ?stack top)
            (!= ?top (bb-read ?browse-rel cycle-end))
            (bb-none ?browse-rel inflight))
      (effects
        (maintain-proposal {@self STACK-TAKE ?top ?stack}
            [/postlude (bb-write ?browse-rel inflight ?top)])))
    (try
      (role ?top (spatial ?stack top)
            (= ?top (bb-read ?browse-rel cycle-end))
            (bb-none ?browse-rel inflight))
      (effects (set-outcome ?browse-rel /succ)))
    (try
      (role @self (bb-any ?browse-rel inflight)
                  (bb-any ?browse-rel verdict kept))
      (effects
        (bb-clear ?browse-rel verdict)
        (bb-clear ?browse-rel inflight)))
    (try
      (role ?doc [k document] (spatial ?doc held-by @self)
            (= ?doc (bb-read ?browse-rel inflight))
            (bb-any ?browse-rel verdict handled))
      (effects
        (maintain-proposal {@self STACK-BURY ?doc ?stack}
            [/postlude (if (not (bb-any ?browse-rel cycle-end))
                          (then (bb-write ?browse-rel cycle-end ?doc)))
                      (bb-clear ?browse-rel verdict)
                      (bb-clear ?browse-rel inflight)])))))
