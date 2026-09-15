; ----------------------------------------------------------------------------
; stack-browse ?stack ?do-this - walk a pile, doing the CALLER'S work to each doc in turn.
; The generic half of every stack errand: it lifts the top into hand, runs what the caller
; handed it, re-files the doc and goes round. It knows nothing about why any doc matters.
;
; ?do-this is a QUOTED body, evaluated once per doc with the doc bound. It reads the doc as
; .?item and the running browse as .?browse-rel - late-bound vars, so they resolve HERE, in
; the rule doing the walking, not in the rule that wrote them. Whatever the caller wants
; done is what it writes:
;
;   '(if (and (mine .?item) -{@self READ .?item /succ})       - read my post as I go
;        (then (maintain-proposal {@self READ .?item})))
;   '(if (is-a .?item [k application])                        - take the one I came for
;        (then (bb-write .?browse-rel keep @true)))
;
; WHAT HAPPENS TO THE DOC after the body has run is decided by where the doc IS:
;   not in his hand  - the body disposed of it (burnt, posted, handed over). Nothing to
;                      re-file; on round the pile.
;   in his hand      - re-file it at the bottom and go round. THE COMMON CASE.
;   in his hand, and the body set `keep` - it is his. The round ends /succ holding it.
; A man has two hands, so `keep` has to end the round.
;
; THE LIFT IS ITS OWN RUNG and the per-doc work is a (sequence ..) whose IDENTITY is the
; doc in flight. That split is the whole of the design. A sequence starts over only when its
; head's identity binds change - an activation's stage is never rewound, and a ceased-then-
; readmitted one resumes where it stood - so the identity has to be the thing that turns
; over once per pass, and that is `inflight`: the lift sets it, the last stage clears it,
; and clearing it retires the activation so the next lift starts a fresh one at stage 1.
; The believed top cannot play that part: the lift CHANGES the top, so a head cast on it
; retires the activation mid-sequence and re-admits it at stage 1 on the next doc - the pile
; walks into his hands one paper a minute and nothing is ever re-filed. The lift rung may
; churn on the top all it likes; it holds no stage state.
;
; THE DOC IN HAND IS THE ONE STACK-TAKE LIFTED, read back off the act under `taken` - never
; the believed top the lift was proposed on. A pile changes under a man between the look and
; the reach, and a round that re-filed the doc it MEANT to lift would wait for ever on a
; paper still lying on the pile.
;
; State on the running act, dying with it:
;   inflight  - the doc lifted this pass; the per-doc sequence's identity
;   keep      - the body claimed it
;   cycle-end - the first doc re-filed this round; when it surfaces as the top again every
;               original doc has been seen and the round is over.
; ----------------------------------------------------------------------------

(npc-task {@self stack-browse ?stack ?do-this}:?browse-rel
  (tar stack)
  (aux ?)
  (and
    (try
      (task-prelude
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then (set-outcome ?browse-rel /succ)))))

    ; THE ROUND IS OVER when the pile has nothing left to show. This LOOKS rather than
    ; reading what @self believes: observing an empty pile teaches a mind nothing at all
    ; (a pile's contents are learned by observing them and by no other route), so `nothing
    ; on top` is never a fact he can hold - only the answer a fresh look gives back.
    (try
      (role @self (bb-none ?browse-rel inflight))
      (when (unknown (spatial ?stack top)))
      (effects
        (tolerate (observe (spatial ?stack top /env)): ?top)
        (if (nothing ?top)
            (then (set-outcome ?browse-rel /succ)))))

    ; FULL CIRCLE: the first doc re-filed is back on top, so every original has been seen.
    (try
      (role ?top (spatial ?stack top)
            (= ?top (bb-read ?browse-rel cycle-end))
            (bb-none ?browse-rel inflight))
      (effects (set-outcome ?browse-rel /succ)))

    ; HE IS KEEPING IT: the body claimed the doc and it is in his hand, so the errand is
    ; done and he walks away with it.
    (try
      (role ?doc [k document] (spatial ?doc held-by @self)
            (= ?doc (bb-read ?browse-rel inflight))
            (bb-any ?browse-rel keep))
      (effects (set-outcome ?browse-rel /succ)))

    ; THE LIFT: one paper at a time, and only when his hand is empty of this round's work.
    ; AT THE STACK - (spatial ?stack top) is what @self BELIEVES is on top, a memory rather
    ; than a reach, so without the co-location gate he goes on lifting from across town and
    ; STACK-TAKE's own precondition catches him at it.
    (try
      (role ?top (spatial ?stack top)
            (!= ?top (bb-read ?browse-rel cycle-end)))
      (role @self (spatial ?stack co-located @self)
                  (bb-none ?browse-rel inflight)
                  (bb-none ?browse-rel keep))
      (effects
        ; A lift that came up empty - the pile went out from under him between the look
        ; and the reach - writes nothing, and the rung simply looks again.
        (maintain-proposal {@self STACK-TAKE ?top ?stack}:?take
            [/postlude (if (bb-any ?take taken)
                           (then (bb-write ?browse-rel inflight (bb-read ?take taken))))])))

    ; ONE DOC, in his hand: do the caller's work, then re-file it.
    (sequence
      (role ?doc [k document] (= ?doc (bb-read ?browse-rel inflight)))
      (role @self (spatial ?stack co-located @self))

      ; THE CALLER'S WORK. ?item is what the body's .?item resolves to - it is named here,
      ; in the rule that evaluates the body, which is the whole of the late-bound mechanism.
      (stage
        (effects
          (bind ?doc ?item)
          (eval ?do-this)))

      ; RE-FILE, unless the body kept it or disposed of it: either way it is not his to put
      ; back. A stage that mints nothing falls through, which is how both of those pass.
      (stage
        (effects
          (if (and (spatial ?doc held-by @self) (bb-none ?browse-rel keep))
              (then (maintain-proposal {@self STACK-BURY ?doc ?stack}
                        [/postlude (if (not (bb-any ?browse-rel cycle-end))
                                      (then (bb-write ?browse-rel cycle-end ?doc)))])))))

      (stage
        (effects (bb-clear ?browse-rel inflight))))))
