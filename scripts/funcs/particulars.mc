; ----------------------------------------------------------------------------
; particulars - the kinds a man meets and comes to like or dislike: a drink he takes. Meeting one
; is felt as warmth toward its KIND by the rule (feel-stance): the particular's population base,
; bent by the trait_affect rows of category taste, by his class, and by an arbitrary fondness or
; aversion drawn at his birth. The favourite of a category is classified off those feelings.
; ----------------------------------------------------------------------------

; Each particular, its category, how a man of average traits takes to it, and its weight when a
; birth draws an arbitrary love or hate.
(define-table particular (fields category particular base draw)
  (record drink [k beer]      0.4 1)
  (record drink [k porter]    0.2 1)
  (record drink [k gin]       0.1 1)
  (record drink [k whisky]    0.2 1)
  (record drink [k claret]    0.3 1)
  (record drink [k tea-drink] 0.4 1)
  (record drink [k coffee]    0.2 1)
  (record drink [k lemonade]  0.2 1))

; What his class adds to meeting a particular.
(define-table particular_class (fields particular class felt)
  (record [k claret]    [k upper]   0.8)
  (record [k claret]    [k middle]  0.3)
  (record [k claret]    [k lower]  -0.3)
  (record [k gin]       [k lower]   0.4)
  (record [k gin]       [k upper]  -0.4)
  (record [k beer]      [k lower]   0.2)
  (record [k tea-drink] [k upper]   0.2)
  (record [k tea-drink] [k middle]  0.2))

; What a born fondness or aversion adds to every meeting of its particular.
(define-macro sensitivity-felt () 2.0)

; The chance a newborn is drawn a fondness, and apart from it an aversion.
(define-macro sensitivity-chance () 0.3)

; The least warmth a particular is held at to be a favourite.
(define-macro favourite-warmth-min () 0.2)

; What a man feels on meeting ?kind.
(define-func particular-felt (?kind)
  (bind 0.0 ?base)
  (if (table-match particular particular ?kind base ?row-base)
      (then (bind ?row-base ?base)))
  (bind (trait-bent ?kind taste ?base) ?felt)
  (any {@self class-situation ?class=@nothing})
  (if (and (substantial ?class) (table-match particular_class particular ?kind class ?class felt ?class-felt))
      (then (bind (+ ?felt ?class-felt) ?felt)))
  (if {@self fondness ?kind}
      (then (bind (+ ?felt (sensitivity-felt)) ?felt)))
  (if {@self aversion ?kind}
      (then (bind (- ?felt (sensitivity-felt)) ?felt)))
  ?felt)

; @self meets ?kind, the meeting ?cause.
(define-func meet-particular (?kind ?cause)
  (feel-stance ?kind warmth (particular-felt ?kind) ?cause))

; A man's arbitrary loves and hates, drawn once at his making or birth.
(define-func seed-sensitivities (?h)
  (if (chance (sensitivity-chance))
      (then (add-attr-item-unique ?h fondness (table-sample-weighted particular particular draw))))
  (if (chance (sensitivity-chance))
      (then (add-attr-item-unique ?h aversion (table-sample-weighted particular particular draw)))))

; Every pub's bar-room stocks a pile of each drink, endless: the publican's cellar is not kept.
(define-macro bar-stock-count () 1000)

(define-func seed-bar-stock ()
  (for-each ?pub (env-entities [k pub-building])
    (premises-place ?pub): ?place
    (for-each ?bar (spatial ?place rooms /env)
      (if (is-a ?bar [k bar-room])
          (then
            (for-each-row particular [/category ?category] [/particular ?drink]
              (if (= ?category drink)
                  (then
                    (if (find-spot [k pile] [/on_floor_of ?bar]): ?spot
                        (then
                          (create-entity [k pile] ?spot): ?pile
                          (set-attr ?pile content-kind ?drink)
                          (set-attr ?pile count (bar-stock-count))))))))))))

; How strongly @self is drawn to ?drink-kind at the bar: his warmth toward it, and an alcoholic
; drink the more for a craving.
(define-macro drink-appeal-floor () 0.1)
(define-macro craving-drink-pull () 3.0)

(define-func drink-appeal (?drink-kind)
  (* (+ (drink-appeal-floor) (+ 1.0 (stance ?drink-kind warmth)))
     (flip (and {@self craving [k alcohol]} (is-a ?drink-kind [k alcoholic-drink])) (craving-drink-pull) 1.0)))
