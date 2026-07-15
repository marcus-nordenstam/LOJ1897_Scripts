; ----------------------------------------------------------------------------
; catch_up (npc-act). An NPC SAYS ALOUD their OWN recent news (a new spouse /
; fiancee / child / friendship) to whoever is co-present. (top-untold-belief @self
; _ @self spouse fiancee lover child) picks the freshest such fact they have not
; already announced (about = @self -> self-news; checked against their {@self
; SAY ...} memories so they do not repeat it), and (tell ...) broadcasts it. A
; listener who hears it files @self as the source and can pass "did you hear, X had
; a child" along - self-news cascades onward as ordinary gossip.
;
; An ACT (tell) carried by perception, so npc-act. CAST-FREE: @self is the
; deliberating NPC and speaks to the room (no second binding role). Fired once per
; NPC per window; the gates (extraversion-weighted chance + a minimum age) live in
; (when). Telling nothing (no fresh news) is a safe no-op.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think catch_up
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (any_human @self)
              (believes {@self friend ?}))

  ; Non-belief gates (out of the role): extraversion-weighted chance + minimum age.
  (when (and (chance (* 0.25 (+ 0.5 (attr @self enthusiasm))))
             (>= (years-old @self) 12)))

  (act-effects
    ; Say ONE untold piece of my OWN news to the room. for-each-belief walks my
    ; {@self <label> ?} beliefs across the relationship labels, binding BOTH the matched
    ; label (the :?label capture) and its target; (utterable-msg) dedups against my SAY
    ; memories; (break) stops at the first untold fact. Telling nothing is a safe no-op.
    (for-each-belief {@self spouse|fiancee|lover|child|home|mother|father|sibling|friend|nationality:?label ?tgt}
      (do
        (if (not (believes {@self SAY (utterable-msg {@self ?label ?tgt}) _}))
            (do (tell {@self ?label ?tgt}) (break)))))
    ))
