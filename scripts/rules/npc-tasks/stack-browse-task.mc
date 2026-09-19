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
; THE ROUND KEEPS NO STATE ABOUT THE PAPER: the paper keeps it. STACK-TAKE writes
; (bb-read ?doc from-stack) when it comes off a pile and STACK-PUT / STACK-BURY clear it
; when it goes back on one, so "the paper I lifted off THIS pile and have not filed again"
; is a question about the world, asked the same way by the rung that must not lift a second
; one and by the (sequence ..) that works the first. That is also what makes the round LOOP:
; a sequence starts over only when its head's identity binds change, and the noted paper
; turns over exactly once per pass. The lift is its own rung for the same reason - it
; churns on the believed top, which the lift itself changes, and a head cast on that retires
; the activation mid-pass and re-admits it at stage 1 on the next doc, so the pile walks
; into his hands one paper a minute and nothing is ever re-filed.
;
; The one thing that IS the round's own: cycle-end, the first doc re-filed this round. When
; it surfaces as the top again every original doc has been seen and the round is over.
; ----------------------------------------------------------------------------

(npc-task {@self stack-browse ?stack ?do-this}:?browse-rel
  (tar stack)
  (aux ?)
  ; THE OPENING LOOK, once, when the round begins - which is what (init ..) is, and why
  ; it sits on the SPINE: it belongs to the whole task, not to any one rung. A pile with
  ; nothing on it was never a round to run.
  (init
    (tolerate (observe (spatial ?stack top /env)): ?opening-top)
    (if (nothing ?opening-top)
        (then (set-outcome ?browse-rel /succ))))
  (and
    ; THE ROUND IS OVER when the pile has nothing left to show. This LOOKS rather than
    ; reading what @self believes: observing an empty pile teaches a mind nothing at all
    ; (a pile's contents are learned by observing them and by no other route), so `nothing
    ; on top` is never a fact he can hold - only the answer a fresh look gives back.
    (try
      (no-role [k document] (= (bb-read ?norole from-stack) ?stack))
      (when (unknown (spatial ?stack top)))
      (effects
        (tolerate (observe (spatial ?stack top /env)): ?fresh-top)
        (if (nothing ?fresh-top)
            (then (set-outcome ?browse-rel /succ)))))

    ; FULL CIRCLE: the first doc re-filed is back on top, so every original has been seen.
    (try
      (role ?circled-top (spatial ?stack top)
            (= ?circled-top (bb-read ?browse-rel cycle-end)))
      (no-role [k document] (= (bb-read ?norole from-stack) ?stack))
      (effects (set-outcome ?browse-rel /succ)))

    ; HE IS KEEPING IT: the body claimed the doc and it is in his hand, so the errand is
    ; done and he walks away with it.
    (try
      (role ?doc [k document] (= (bb-read ?doc from-stack) ?stack)
            (spatial ?doc held-by @self)
            (bb-any ?browse-rel keep))
      (effects (set-outcome ?browse-rel /succ)))

    ; THE LIFT: one paper at a time - the no-role is "I am not already working one off this
    ; pile". AT THE STACK: (spatial ?stack top) is what @self BELIEVES is on top, a memory
    ; rather than a reach, so without the co-location gate he lifts from across town.
    (try
      (role ?lift-top (spatial ?stack top)
            (!= ?lift-top (bb-read ?browse-rel cycle-end)))
      (no-role [k document] (= (bb-read ?norole from-stack) ?stack))
      (role @self (spatial ?stack co-located @self)
                  (bb-none ?browse-rel keep))
      ; A HAND TO LIFT IT WITH. stack-take asserts one is free - a proposer reaching with
      ; full hands is an authoring error, and this is the only rung that proposes it. The
      ; round simply waits: whatever he is holding is something he came here carrying, and
      ; the pile is not going anywhere.
      (when (or (empty (spatial (spatial @self left-hand) grip))
                (empty (spatial (spatial @self right-hand) grip))))
      (effects (maintain-proposal {@self stack-take ?stack})))

    ; ONE DOC: do the caller's work, then re-file it.
    (sequence
      (role ?doc [k document] (= (bb-read ?doc from-stack) ?stack))
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
                                      (then (bb-write ?browse-rel cycle-end ?doc)))]))))))))
