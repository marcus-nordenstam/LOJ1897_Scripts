; ----------------------------------------------------------------------------
; take-applications ?stack - the office post round: the recruiting officer reads every
; application on ?stack. The office twin of take-my-letters, and the only difference is the
; one line of body it hands to the generic stack-browse.
; ----------------------------------------------------------------------------

(npc-task {@self take-applications ?stack}:?take-apps-rel
  (aspect labour)
  (tar @excl stack)
  (and
    (try
      (role @self -{@self stack-browse ?stack ? /succ /caused_by ?take-apps-rel})
      (utility obligation)
      (effects
        (maintain-proposal
          {@self stack-browse ?stack
            '(if (and (is-a .?item [k application])
                      -{@self READ .?item /succ})
                 (then (maintain-proposal {@self READ .?item})))})))
    (try
      (role @self {@self stack-browse ?stack ? /succ /caused_by ?take-apps-rel})
      (effects (set-outcome ?take-apps-rel /succ)))))
