; The conversation gauntlets' shared funcs, included by one config per case (c01-pair.mc,
; c02-three.mc ..). Seeds state only; nothing here behaves.

; The first residential building that holds a unit, as its unit: a chapel is a residential
; building too, and has none.
(include "../../../macros/occasion-macros.mc")
(include "../../../macros/home-macros.mc")

(define-func conversation-first-home ()
  (bind @nothing ?home)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit) (then (bind ?unit ?home) (break))))
  (check (substantial ?home))
  ?home)

; How far apart the presented group's home and the unpresented group's must be: past the
; presentation bubble's range (96 m, t_presentation_bubble::k_present_range_m) with room to spare.
(define-macro k-conversation-apart-m () 200.0)

; (conversation-far-home ?near) - the residential unit farthest from ?near: the unpresented group's
; home, out of the presented group's bubble and earshot.
(define-func conversation-far-home (?near)
  (bind @nothing ?far)
  (bind 0.0 ?far-m)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit)
        (then
          (distance (spatial ?unit bounds /env) (spatial ?near bounds /env)): ?unit-m
          (if (> ?unit-m ?far-m) (then (bind ?unit ?far) (bind ?unit-m ?far-m))))))
  (check (> ?far-m (k-conversation-apart-m)))
  ?far)

; (conversation-third-home ?a ?b) - the residential unit farthest from both ?a and ?b: a home for
; people the groups know of but who live in neither of their homes.
(define-func conversation-third-home (?a ?b)
  (bind @nothing ?third)
  (bind 0.0 ?third-m)
  (for-each ?house (env-entities [k residential-building])
    (head (spatial ?house parts [k unit] /env)): ?unit
    (if (substantial ?unit)
        (then
          (distance (spatial ?unit bounds /env) (spatial ?a bounds /env)): ?unit-a-m
          (distance (spatial ?unit bounds /env) (spatial ?b bounds /env)): ?unit-b-m
          (min ?unit-a-m ?unit-b-m): ?unit-m
          (if (> ?unit-m ?third-m) (then (bind ?unit ?third) (bind ?unit-m ?third-m))))))
  (check (> ?third-m (k-conversation-apart-m)))
  ?third)

; (conversation-engage ?woman ?home) - ?woman has just got engaged to a man of ?home: news of her own
; she has told nobody. A belief seeded before the run is not born in it, so the news the speech-value
; reflex would mint is seeded with it.
(define-func conversation-engage (?woman ?home)
  (make-human ?home [k lower] [k male]): ?ce-man
  (enter-mind ?woman)
  (observe ?ce-man): ?ce-fiance
  (begin-belief {@self fiancee ?ce-fiance}): ?ce-engaged
  (begin-belief {@self news ?ce-engaged})
  (exit-mind))

; (holds-engagement-of ?other) - in a mind: @self knows whom ?other is engaged to.
(define-func holds-engagement-of (?other)
  (substantial (any {?other fiancee ?})))

; (conversation-household ?home) - everyone under ?home's roof knows every other one by name, and
; that they share the home.
(define-func conversation-household (?home)
  (for-each ?ch-a (env-entities [k human])
    (if (spatial ?ch-a unit ?home /env)
        (then
          (for-each ?ch-b (env-entities [k human])
            (if (and (neq ?ch-a ?ch-b) (spatial ?ch-b unit ?home /env))
                (then (seed-housemate-half ?ch-a ?ch-b))))))))

; (conversation-wed ?a ?b) - ?a and ?b are married, each in his own mind.
(define-func conversation-wed (?a ?b)
  (enter-mind ?a)
  (observe ?b): ?cw-b
  (begin-belief {@self spouse ?cw-b})
  (exit-mind)
  (enter-mind ?b)
  (observe ?a): ?cw-a
  (begin-belief {@self spouse ?cw-a})
  (exit-mind))

; (conversation-knows-mealtimes ?who ?home) - ?who has long known ?home's meal hours, as the one who
; set them holds them: she has no need to set them, and those who wonder about them can ask her.
(define-func conversation-knows-mealtimes (?who ?home)
  (enter-mind ?who)
  (observe ?home): ?ckm-home
  (begin-belief {?ckm-home breakfast-hour (household-breakfast-hour)})
  (begin-belief {?ckm-home lunch-hour (household-lunch-hour)})
  (begin-belief {?ckm-home supper-hour (household-supper-hour)})
  (exit-mind))

; (knows-supper-hour) - in a mind: @self knows his home's supper hour.
(define-func knows-supper-hour ()
  (any {@self home ?ksh-home})
  (substantial (any {?ksh-home supper-hour ?})))

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
  (for-each ?ask (every {@self SAY (qs ? (news-for ?..)) ?other /succ})
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

; (left-talk ?who) - ?who ended his part in a talk himself: he said his goodbye to it, or, called
; away, gave his account of what called him.
(define-func left-talk (?who)
  (in-mind ?who (substantial (any {@self SAY (formulaic ? leave_taking ?..) ? /past}))))

; (took-in ?caller) - in a mind: @self answered an opening ?caller said to her by taking him in -
; taking his talk up, or answering it inside her own talk, which a caller joins before he opens.
(define-func took-in (?caller)
  (bind @false ?took)
  (for-each ?opening (every {?caller SAY (formulaic ? opening-phrase ?..) @self /past})
    (if (or (substantial (any {@self take-up ?caller /succ /caused_by ?opening}))
            (substantial (any {@self respond ?caller ?opening /succ})))
        (then (bind @true ?took) (break))))
  ?took)

; (talked-with ?caller) - in a mind: @self came to talk with ?caller, whose hail she turned down or
; took in: she took him in, or he took up the hail she owed him back.
(define-func talked-with (?caller)
  (or (took-in ?caller) (substantial (any {@self hail ?caller /succ /ever}))))

; (knows-talk-with ?a ?b) - in a mind: @self knows a talk he took part in that ?a and ?b took part in too.
(define-func knows-talk-with (?a ?b)
  (bind @false ?found)
  (for-each ?part (every {? participant @self /ever})
    (bind ?part.subject ?talk)
    (if (and (substantial (any {?talk participant ?a /ever})) (substantial (any {?talk participant ?b /ever})))
        (then (bind @true ?found) (break))))
  ?found)
