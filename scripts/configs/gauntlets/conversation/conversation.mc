; The conversation gauntlets' shared funcs, included by one config per case (c01-pair.mc,
; c02-three.mc ..). Seeds state only; nothing here behaves.

; The first residential building that holds a unit, as its unit: a chapel is a residential
; building too, and has none.
(define-func conversation-first-home ()
  (bind @nothing ?home)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit) (then (bind ?unit ?home) (break))))
  (check (substantial ?home))
  ?home)

; (spoken-over) - in a mind: the lines two different men said to @self at once, each pair counted
; from both of its lines. A jump-clock line lasts exactly one second, so two that overlap end in
; the same second.
(define-func spoken-over ()
  (bind 0 ?pairs)
  (bind (every {? SAY ? @self /past}) ?lines)
  (for-each ?first-line ?lines
    (bind ?first-line.subject ?first-speaker)
    (bind (elapsed /seconds ?first-line) ?first-end)
    (for-each ?second-line ?lines
      (bind ?second-line.subject ?second-speaker)
      (bind (elapsed /seconds ?second-line) ?second-end)
      (if (and (neq ?first-speaker ?second-speaker) (= ?first-end ?second-end))
          (then (bind (+ ?pairs 1) ?pairs)))))
  ?pairs)

; (conversation-befriend ?a ?b) - ?a and ?b are friends, each in his own mind.
(define-func conversation-befriend (?a ?b)
  (enter-mind ?a)
  (observe ?b): ?cb-friend
  (begin-belief {@self friend ?cb-friend})
  (exit-mind)
  (enter-mind ?b)
  (observe ?a): ?cb-friend-back
  (begin-belief {@self friend ?cb-friend-back})
  (exit-mind))

; (asked-whats-new ?other) - in a mind: @self asked ?other what is new, and he replied to it.
(define-func asked-whats-new (?other)
  (bind @false ?asked)
  (for-each ?ask (every {@self SAY (qs ? (pick-untold-belief ?..)) ?other /succ})
    (if (replied ?other ?ask)
        (then (bind @true ?asked) (break))))
  ?asked)

; (answered-tidings ?other) - in a mind: ?other told @self tidings, and @self answered them in kind -
; a friend-talk of his caused by that line.
(define-func answered-tidings (?other)
  (bind @false ?answered)
  (for-each ?line (every {?other SAY (msg ~[/msg-class tidings] ?..) @self /past})
    (if (substantial (any {@self friend-talk ? ?other /ever /caused_by ?line}))
        (then (bind @true ?answered) (break))))
  ?answered)

; (knows-talk-with ?a ?b) - in a mind: @self knows a talk he took part in that ?a and ?b took part in too.
(define-func knows-talk-with (?a ?b)
  (bind @false ?found)
  (for-each ?part (every {? participant @self /ever})
    (bind ?part.subject ?talk)
    (if (and (substantial (any {?talk participant ?a /ever})) (substantial (any {?talk participant ?b /ever})))
        (then (bind @true ?found) (break))))
  ?found)
