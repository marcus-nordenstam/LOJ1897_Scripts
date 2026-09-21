; ----------------------------------------------------------------------------
; take-applications ?stack - the office post round: the recruiting officer reads every
; application on ?stack. The office twin of take-my-letters, and the only difference is the
; one line of body it hands to the generic stack-browse.
; ----------------------------------------------------------------------------

(npc-task {@self take-applications ?stack}:?take-apps-rel
  (aspect labour)
  (tar @excl [k stack] @object)
  (and
    (try
      (role @self -{@self stack-browse ?stack ? /succ /caused_by ?take-apps-rel}
        (utility obligation)
        (effects
          (maintain-proposal
            {@self stack-browse ?stack
              ; A form he has not read, he reads. One he HAS read is spent - its facts are
              ; beliefs now, and the man's own apply-for is the queue the paper stood in - so
              ; he burns it. Disposing of it HERE, as the round's work on the doc in hand, is
              ; what the round expects: a doc the body got rid of is not re-filed. A rung of
              ; its own instead raced the round and burnt the paper marking cycle-end, which
              ; left the round no way to end but to empty the pile.
              '(if (is-a .?item [k application])
                   (then (if -{@self READ .?item /succ}
                             (then (maintain-proposal {@self READ .?item}))
                             (else (maintain-proposal {@self DESTROY-ENTITY .?item})))))}))))
    (try
      (role @self {@self stack-browse ?stack ? /succ /caused_by ?take-apps-rel}
        (effects (set-outcome ?take-apps-rel /succ))))))
