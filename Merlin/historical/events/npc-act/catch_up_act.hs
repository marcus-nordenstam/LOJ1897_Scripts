; ----------------------------------------------------------------------------
; catch_up (npc-think). Away from the table, @self SAYS ALOUD their OWN recent news
; (a new spouse / fiancee / child / friendship) to whoever is CO-PRESENT. The
; listener ?guest is bound by the location JOIN ({@self location ?loc} + {?guest
; location ?loc}, cf. introduce.hs - the guest perceived sharing @self's room), and
; @self tells each ONE fact they have not heard. Hearing it, a guest files @self as
; the source and can pass "did you hear, X had a child" along - self-news cascades
; onward as ordinary gossip.
;
; Fired per NPC per window; the gates (extraversion-weighted chance + a minimum
; age) live in (when). Dedup is PER-LISTENER (the SAY's aux is the guest), so a
; guest hears each fact only once. Telling nothing (all heard, or nobody
; co-present) is a safe no-op. Meal-table chatter is table_talk_think.hs.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think catch_up
  (sim-window-think)
  (rng-stream behaviour)

  ; ?guest is anyone CO-PRESENT (the location JOIN, cf. introduce.hs): @self's own
  ; room off {@self location ?loc}, the guest perceived in that same room. Enumerated,
  ; so each co-present listener hears their own untold slice of @self's news.
  (role ?guest (any_human ?guest)
               (believes {?guest location (target {@self location})}))

  ; Non-belief gates (out of the role): extraversion-weighted chance + minimum age.
  (when (and ;(co-present @self ?guest)
             (chance (* 0.25 (+ 0.5 (attr @self enthusiasm))))
             (>= (years-old @self) 12)))

  (act-effects
    ; Tell ?guest ONE piece of my OWN news they have not heard. for-each-belief walks my
    ; {@self <label> ?} beliefs across the relationship labels, binding the matched label
    ; (the :?label capture) + its target; the dedup is PER-GUEST - the SAY's aux is the
    ; listener, so {@self SAY <msg> ?guest} is "have I told THIS guest this". (break)
    ; stops at the first untold fact. Telling nothing is a safe no-op.
    (for-each-belief ?belief {@self spouse|fiancee|lover|child|home|mother|father|sibling|friend|nationality ?}
      (do
        (if (not (believes {@self SAY (utterable-msg ?belief) ?guest}))
            (do (tell-to ?guest ?belief) (break)))))
    ))
