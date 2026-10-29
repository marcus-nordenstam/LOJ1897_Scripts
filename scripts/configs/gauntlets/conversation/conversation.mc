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

; (conversation-see-weather ?who ?town) - ?who has seen the town's weather: he perceives the town.
(define-func conversation-see-weather (?who ?town)
  (enter-mind ?who)
  (observe ?town)
  (exit-mind))

; (answered-smalltalk ?other) - in a mind: ?other made a smalltalk remark to @self, and @self
; answered it - a line of his caused by that remark.
(define-func answered-smalltalk (?other)
  (bind @false ?answered)
  (for-each ?line (every {?other SAY (msg ~[/msg-class smalltalk] ?..) @self /past})
    (if (substantial (any {@self tell ? ?other /succ /caused_by ?line}))
        (then (bind @true ?answered) (break))))
  ?answered)

; (answered-flirt ?other) - in a mind: ?other flirted with @self, and @self answered it - a line of
; his caused by that flirt.
(define-func answered-flirt (?other)
  (bind @false ?answered)
  (for-each ?line (every {?other SAY (formulaic ~[/msg-class flirtation] flirt compliment) @self /past})
    (if (substantial (any {@self tell ? ?other /succ /caused_by ?line}))
        (then (bind @true ?answered) (break))))
  ?answered)

; (asked-whats-new ?other) - in a mind: @self asked ?other what is new, and he replied to it.
(define-func asked-whats-new (?other)
  (bind @false ?asked)
  (for-each ?ask (every {@self SAY (qs ? (pick-untold-belief ?..)) ?other /succ})
    (if (replied ?other ?ask)
        (then (bind @true ?asked) (break))))
  ?asked)

; (responded-to-tidings ?other) - in a mind: every line of tidings ?other told @self has a line of
; @self's in response, caused by it - his own tidings when he had some, else its receipt.
(define-func responded-to-tidings (?other)
  (bind @true ?responded)
  (for-each ?line (every {?other SAY (msg ~[/msg-class tidings] ?..) @self /past})
    (if (unsubstantial (any {@self tell ? ?other /succ /caused_by ?line}))
        (then (bind @false ?responded) (break))))
  ?responded)

; (left-talk ?who) - ?who ended his part in a talk himself: he took his leave, or, called away,
; gave his account of what called him.
(define-func left-talk (?who)
  (or (> (acts ?who take-leave succ) 0)
      (in-mind ?who (substantial (any {@self SAY (formulaic ? leave_taking excuse ?) ? /past})))))

; (knows-talk-with ?a ?b) - in a mind: @self knows a talk he took part in that ?a and ?b took part in too.
(define-func knows-talk-with (?a ?b)
  (bind @false ?found)
  (for-each ?part (every {? participant @self /ever})
    (bind ?part.subject ?talk)
    (if (and (substantial (any {?talk participant ?a /ever})) (substantial (any {?talk participant ?b /ever})))
        (then (bind @true ?found) (break))))
  ?found)
