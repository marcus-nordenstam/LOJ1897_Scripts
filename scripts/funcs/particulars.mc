; ----------------------------------------------------------------------------
; particulars - the kinds a man meets and comes to like or dislike: a drink he takes, a dish he
; eats, a book he reads, and his pet peeves, rudeness and drink seen in others. Meeting one
; is felt as warmth toward its KIND by the rule (feel-stance): the particular's population base,
; bent by the trait_affect rows of category taste, by his class, and by an arbitrary fondness or
; aversion drawn at his birth. The favourite of a category is classified off those feelings.
; ----------------------------------------------------------------------------

; Each category's particulars, how a man of average traits takes to each, and its weight when one
; is drawn: a birth's arbitrary love or hate, a study's shelf.
(define-table drink_particulars (fields particular base draw)
  (record [k beer]      0.4 1)
  (record [k porter]    0.2 1)
  (record [k gin]       0.1 1)
  (record [k whisky]    0.2 1)
  (record [k claret]    0.3 1)
  (record [k tea-drink] 0.4 1)
  (record [k coffee]    0.2 1)
  (record [k lemonade]  0.2 1))

(define-table food_particulars (fields particular base draw)
  (record [k roast-beef] 0.5 1)
  (record [k mutton] 0.3 1)
  (record [k pie] 0.4 1)
  (record [k fish] 0.2 1)
  (record [k oyster] 0.1 1)
  (record [k curry] 0.0 1)
  (record [k pickles] 0.1 1)
  (record [k pudding] 0.4 1)
  (record [k bread] 0.3 1)
  (record [k cheese-food] 0.3 1))

; A pet peeve: an act of OTHERS @self comes to mind, his feeling toward its kind the aversion that
; lowers his warmth toward whoever he sees doing it.
(define-table peeve_particulars (fields particular base)
  (record [k insult]          -0.2)
  (record [k alcoholic-drink]  0.0))

(define-table reading_particulars (fields particular base draw)
  (record [k sermon-book] 0.2 1)
  (record [k romance-novel] 0.2 1)
  (record [k adventure-novel] 0.2 1)
  (record [k detective-novel] 0.2 1)
  (record [k scientific-romance] 0.2 1)
  (record [k penny-dreadful] 0.2 1)
  (record [k poetry-book] 0.2 1)
  (record [k almanac] 0.2 1))

; What his class adds to meeting a particular.
(define-table particular_class (fields particular class felt)
  (record [k claret]    [k upper]   0.8)
  (record [k claret]    [k middle]  0.3)
  (record [k claret]    [k lower]  -0.3)
  (record [k gin]       [k lower]   0.4)
  (record [k gin]       [k upper]  -0.4)
  (record [k beer]      [k lower]   0.2)
  (record [k tea-drink] [k upper]   0.2)
  (record [k tea-drink] [k middle]  0.2)
  (record [k penny-dreadful] [k lower] 0.3)
  (record [k penny-dreadful] [k upper] -0.4)
  (record [k poetry-book] [k upper] 0.2)
  (record [k oyster] [k upper] 0.4)
  (record [k oyster] [k lower] -0.2))

; What a born fondness or aversion adds to every meeting of its particular.
(define-macro sensitivity-felt () 2.0)

; The chance a newborn is drawn a fondness, and apart from it an aversion.
(define-macro sensitivity-chance () 0.3)

; The least warmth a particular is held at to be a favourite.
(define-macro favourite-warmth-min () 0.2)

; What a man feels on meeting ?kind.
(define-func particular-felt (?kind)
  (bind 0.0 ?base)
  (if (table-match drink_particulars particular ?kind base ?drink-base)
      (then (bind ?drink-base ?base)))
  (if (table-match reading_particulars particular ?kind base ?reading-base)
      (then (bind ?reading-base ?base)))
  (if (table-match peeve_particulars particular ?kind base ?peeve-base)
      (then (bind ?peeve-base ?base)))
  (if (table-match food_particulars particular ?kind base ?food-base)
      (then (bind ?food-base ?base)))
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
      (then (add-attr-item-unique ?h fondness (draw-particular))))
  (if (chance (sensitivity-chance))
      (then (add-attr-item-unique ?h aversion (draw-particular)))))

; One particular of any category, a category as likely as another.
(define-func draw-particular ()
  (random-int 0 2): ?category
  (cond (case (= ?category 0) (table-sample-weighted drink_particulars particular draw))
        (case (= ?category 1) (table-sample-weighted reading_particulars particular draw))
        (else (table-sample-weighted food_particulars particular draw))))

; Every pub's bar-room stocks a pile of each drink, endless: the publican's cellar is not kept.
(define-macro bar-stock-count () 1000)

(define-func seed-bar-stock ()
  (for-each ?pub (env-entities [k pub-building])
    (premises-place ?pub): ?place
    (for-each ?bar (spatial ?place rooms /env)
      (if (is-a ?bar [k bar-room])
          (then
            (for-each-row drink_particulars [/particular ?drink]
              (if (find-spot [k pile] [/on_floor_of ?bar]): ?spot
                  (then
                    (create-entity [k pile] ?spot): ?pile
                    (set-attr ?pile content-kind ?drink)
                    (set-attr ?pile count (bar-stock-count))))))))))

; How strongly @self is drawn to ?drink-kind at the bar: his warmth toward it, and an alcoholic
; drink the more for a craving.
(define-macro drink-appeal-floor () 0.1)
(define-macro craving-drink-pull () 3.0)

(define-func drink-appeal (?drink-kind)
  (* (+ (drink-appeal-floor) (+ 1.0 (stance ?drink-kind warmth)))
     (flip (and {@self craving [k alcohol]} (is-a ?drink-kind [k alcoholic-drink])) (craving-drink-pull) 1.0)))

; Every study is shelved with a few books, drawn from the reading particulars.
(define-macro study-books () 3)

(define-func seed-study-books ()
  (for-each ?study (env-entities [k study])
    (repeat (study-books)
      (bind (table-sample-weighted reading_particulars particular draw) ?genre)
      (if (find-spot ?genre [/on_floor_of ?study]): ?spot
          (then (create-entity ?genre ?spot))))))

; How strongly @self is drawn to a book of ?genre on his shelf.
(define-func book-appeal (?genre)
  (+ (drink-appeal-floor) (+ 1.0 (stance ?genre warmth))))

; How far a pet peeve, held at its full aversion, lowers @self's warmth toward the one he sees at it.
(define-macro peeve-felt-scale () 1.0)

; @self sees ?doer at an act of the peeve ?kind, the sight ?cause: he meets the kind, then feels his
; aversion to it toward ?doer.
(define-func witness-peeve (?doer ?kind ?cause)
  (meet-particular ?kind ?cause)
  (bind (min 0.0 (stance ?kind warmth)) ?aversion)
  (if (< ?aversion 0.0)
      (then (feel-stance ?doer warmth (* (peeve-felt-scale) ?aversion) ?cause))))
