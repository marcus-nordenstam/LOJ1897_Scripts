; ----------------------------------------------------------------------------
; catch_up (npc-think). Away from the table, @self proposes SAYING their OWN recent
; news (a new spouse / fiancee / child / friendship) to whoever is CO-PRESENT; the
; shared say_to act says it aloud. The listener ?guest is bound by the location
; JOIN ({@self location ?loc} + {?guest location ?loc}, cf. introduce.hs - the guest
; perceived sharing @self's room), and @self proposes ONE fact they have not heard.
; Hearing it, a guest files @self as the source and can pass "did you hear, X had a
; child" along - self-news cascades onward as ordinary gossip.
;
; Fired per NPC monthly; the gates (extraversion-weighted chance + a minimum
; age) live in (when). Dedup is PER-LISTENER (the SAY's aux is the guest), so a
; guest hears each fact only once. Proposing nothing (all heard, or nobody
; co-present) is a safe no-op. Meal-table chatter is table_talk_think.hs.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think catch_up
  (cooldown 1 m)
  (rng-stream behaviour)

  ; ?guest is anyone CO-PRESENT: sourced OBJECTIVELY from @self's current room (env
  ; contents), each guest passively perceived - enumerated, so each co-present listener
  ; hears their own untold slice of @self's news.
  (role ?guest (any_human ?guest)
               (co-present @self))

  ; Non-belief gates (out of the role): extraversion-weighted chance + minimum age.
  (when (and (chance (* 0.25 (+ 0.5 (attr @self enthusiasm))))
             (>= (years-old @self) 12)))

  (utility 18)

  (effects
    ; Propose telling ?guest ONE piece of my OWN news they have not heard. for-each-present-tense-belief
    ; walks my {@self <label> ?} beliefs across the relationship labels, binding the matched
    ; label + its target; the dedup is PER-GUEST - the SAY's aux is the listener, so {@self
    ; SAY <msg> ?guest} is "have I told THIS guest this". (break) stops at the first untold
    ; fact. Proposing nothing is a safe no-op.
    (for-each-present-tense-belief ?belief {@self spouse|fiancee|lover|child|home|mother|father|sibling|friend|nationality ?}
      (do
        (utterable-msg ?belief): ?msg
        (if (none {@self SAY ?msg ?guest})
            (then (maintain-proposal {@self say_to ?msg ?guest}) (break)))))
    ))
