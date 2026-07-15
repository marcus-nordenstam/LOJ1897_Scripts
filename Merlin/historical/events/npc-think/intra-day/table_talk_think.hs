; ----------------------------------------------------------------------------
; table_talk (npc-think). The mealtime chatter, split OUT of eat_act so it can
; ROLE-CAST its listener (eat_act cannot bind an audience). While @self is seated
; at a meal - a live {@self eat ...} act-goal AND @self AT its place - they turn to
; ONE co-present diner and air ONE piece of their OWN news that diner has not
; heard. Hearing it, the diner files @self as the source and it cascades onward as
; ordinary gossip. table_talk is SELF-SUBJECT only (news of @self); circle news -
; what @self knows OF SOMEONE ELSE - is the town-wide gossip event's job (co-present).
;
; THE LISTENER is a ROULETTE over the co-present set (presumably the family at a
; home supper; tablemates / co-workers / pub company elsewhere). Co-presence is the
; location JOIN {@self location ?loc} + {?diner location ?loc} (the introduce.hs
; pattern - the (co-present) op is NOT a role filter), and (select ... roulette)
; draws one. DEDUP IS PER-LISTENER: the SAY's aux is the diner, so {@self SAY <msg>
; ?diner} reads "have I already told THIS diner this fact"; (break) stops at the
; first untold one. Telling nothing (all heard, or dining alone) is a safe no-op.
;
; ONLY WHILE DINING: the {@self eat ...} goal is live from the desire's mint through
; eat_act's completion, so this fires the once, at the table - the at-place gate
; keeps it off the approach walk, and the goal ending (end-act) closes the window.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think table_talk
  (short-term-think)
  (rng-stream behaviour)

  ; DINING GATE (cached self-gate, so it rejects the non-dining O(1) BEFORE the
  ; ?diner pool materializes): a live eat act-goal. The aux (?place) is not object-
  ; cacheable in a role filter, so the existence caches here and the place binds
  ; in (when) below.
  (role @self (believes {@self eat ?}))

  ; THE LISTENER: one co-present diner, drawn by roulette. The location JOIN binds
  ; @self's own room off {@self location ?loc}, then the diner must be perceived in
  ; that same room.
  (role ?diner (any_human ?diner)
               (believes {?diner location (target {@self location})})
               (select (score 1) (policy roulette)))

  ; Bind the meal place, then require @self to be AT it - seated, not still walking
  ; there (the eat goal is live throughout the approach too).
  (when (and (bind {@self eat ? ?place})
             (at-place ?place)))

  (act-effects
    ; SELF-DISCLOSURE: one untold piece of my own profile. for-each-belief walks my
    ; {@self <label> ?} beliefs across the labels, binding each as ?belief; (break)
    ; stops at the first the diner has not heard.
    (for-each-belief ?belief {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life_aim ?}
      (do
        (if (not (believes {@self SAY (utterable-msg ?belief) ?diner}))
            (do (tell-to ?diner ?belief) (break)))))))
