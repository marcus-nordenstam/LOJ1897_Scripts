; ----------------------------------------------------------------------------
; catch-up (think). Away from the table, @self tells one co-present listener - the nearest
; who has not yet heard it all - ONE piece of his own news (a new spouse / fiancee / child /
; friendship). Hearing it, a guest files @self as the source and can pass "did you hear, X had
; a child" along - self-news cascades onward as ordinary gossip.
;
; The gates (extraversion-weighted chance + a minimum age) live in (when). Dedup is
; PER-LISTENER (the tell's aux is the guest), so a guest hears each fact only once.
; Meal-table chatter is table_talk_think.mc.
; ----------------------------------------------------------------------------


; The first piece of @self's own news ?guest has not been told, or @nothing. The dedup is per
; listener: the tell's aux is the guest, so {@self tell <msg> ?guest /succ} is "have I told
; THIS guest this".
(define-func catch-up-news-for (?guest)
  (bind @nothing ?untold)
  (for-each ?belief (every {@self spouse|fiancee|lover|child|home|mother|father|sibling|friend|nationality ?})
    (utterable-msg [] ?belief): ?msg
    (if -{@self tell ?msg ?guest /succ}
        (then (bind ?msg ?untold)
              (break))))
  ?untold)

(think catch-up
  (cooldown 1 m try-once)
  (rng-stream behaviour)
  ; ?guest is one co-present listener with news of his still untold, the nearest: a crowd is
  ; caught up with one face after another.
  (role @self {@self enthusiasm ?enthusiasm}
              {@self age ?age}
    (role ?guest {?guest isa [k human], condition [k alive]}
                 (spatial ?guest co-located @self)
                 (substantial (catch-up-news-for ?guest))
                 (select (score (near @self ?guest)) (policy argmax unknown-last))

      ; His age rides the @self role; the extraversion-weighted chance is a non-belief gate.
      (when (and (chance (* 0.25 (+ 0.5 ?enthusiasm)))
                 (>= ?age 12)))

      (declare-utility want)

      (effects
        (catch-up-news-for ?guest): ?msg
        (maintain-proposal {@self tell ?msg ?guest})))))
