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
; home supper; tablemates / co-workers / pub company elsewhere). Co-presence is @self
; and ?diner sharing a location, expressed as the location co-location role filter, and
; (select ... roulette) draws one. DEDUP IS PER-LISTENER: the SAY's aux is the diner, so {@self SAY <msg>
; ?diner} reads "have I already told THIS diner this fact"; (break) stops at the
; first untold one. Telling nothing (all heard, or dining alone) is a safe no-op.
;
; ONLY WHILE DINING: gated on the RUNNING {@self eat ...} task, so this fires at
; the table - the at-place gate keeps it off the approach walk, and the task's
; end closes the window.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think table_talk
  (rng-stream behaviour)

  ; DINING GATE (barred BEFORE any role work, so the non-dining reject never
  ; materializes the ?diner pool): the running eat task, its place bound off
  ; the gate's aux.
  (task {@self eat ? ?place})

  ; THE LISTENER: one co-present diner, drawn by roulette. Sourced OBJECTIVELY from
  ; @self's current room (env contents), each diner passively perceived.
  (role ?diner (any_human ?diner)
               (co-present ?diner @self)
               (select (score 1) (policy roulette)))

  ; AT the place - seated, not still walking there (the task can outlive a
  ; mid-meal excursion).
  (when (or (in-building @self ?place) (at_location @self ?place)))

  (utility 20)

  (effects
    ; SELF-DISCLOSURE: one untold piece of my own profile. for-each-present-tense-belief walks my
    ; {@self <label> ?} beliefs across the labels, binding each as ?belief; (break)
    ; stops at the first the diner has not heard and proposes telling it (the shared say_to act
    ; says it aloud).
    (for-each ?belief (every {@self spouse|fiancee|child|job|interest|birthplace|home|mother|father|sibling|friend|nationality|calling|value|life_aim ?})
      (do
        (utterable-msg ?belief): ?msg
        (if (none {@self SAY ?msg ?diner})
            (then (maintain-proposal {@self say_to ?msg ?diner}) (break)))))))
