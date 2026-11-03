; ----------------------------------------------------------------------------
; particulars - the kinds a man meets: a drink he takes, a dish he eats, a book he reads.
;
; An ACQUIRED TASTE: each meeting moves his warmth toward the kind by the rule (feel-stance) - the
; particular's population base, bent by the trait_affect rows of category taste and by his class -
; and the favourite of a category is classified off those feelings.
; A SENSITIVITY: a love or hate of a kind he holds from the start, {@self fondness|aversion <kind>}
; - drawn at birth (thinks/born-fondness-think.mc, born-aversion-think.mc) or his temperament's (a pet peeve,
; thinks/classify/classify-pet-peeves.mc). It never moves; meeting its kind is felt at once as an
; emotion caused by the meeting and by the sensitivity itself: delight or disgust at his own, anger
; at another man doing it.
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

; The chance a man is born with a fondness, and apart from it an aversion.
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
  (if (table-match food_particulars particular ?kind base ?food-base)
      (then (bind ?food-base ?base)))
  (bind (trait-bent ?kind taste ?base) ?felt)
  (any {@self class-situation ?class=@nothing})
  (if (and (substantial ?class) (table-match particular_class particular ?kind class ?class felt ?class-felt))
      (then (bind (+ ?felt ?class-felt) ?felt)))
  ?felt)

; How long the feeling a sensitivity sets off is felt, in hours.
(define-macro sensitivity-delight-hours () 6)
(define-macro sensitivity-disgust-hours () 12)
(define-macro sensitivity-anger-hours () 24)

; The ?label (fondness or aversion) @self holds toward ?kind or a kind it is a kind of, or @nothing.
(define-func sensitivity-to (?label ?kind)
  (bind @nothing ?held)
  (for-each ?sensitivity (every {@self ?label ?})
    (if (is-a ?kind ?sensitivity.target)
        (then (bind ?sensitivity ?held) (break))))
  ?held)

; @self meets ?kind in his own ?act: his taste for it moves, and a sensitivity he holds toward it is
; felt at once - delight or disgust, caused by the act and by the sensitivity.
(define-func meet-particular (?kind ?act)
  (feel-stance ?kind warmth (particular-felt ?kind) ?act)
  (bind (sensitivity-to fondness ?kind) ?fond)
  (if (substantial ?fond)
      (then (mint-emotion-through [k joy] @nothing (sensitivity-delight-hours) ?act ?fond)))
  (bind (sensitivity-to aversion ?kind) ?averse)
  (if (substantial ?averse)
      (then (mint-emotion-through [k disgust] @nothing (sensitivity-disgust-hours) ?act ?averse))))

; @self sees ?doer at ?act on a thing of ?kind: an aversion he holds toward it angers him at ?doer,
; caused by the act and by the aversion - his pet peeve.
(define-func witness-aversion (?doer ?kind ?act)
  (bind (sensitivity-to aversion ?kind) ?averse)
  (if (substantial ?averse)
      (then (mint-emotion-through [k anger] ?doer (sensitivity-anger-hours) ?act ?averse))))

; One particular of any category, a category as likely as another.
(define-func draw-particular ()
  (random-int 0 2): ?category
  (cond (case (= ?category 0) (table-sample-weighted drink_particulars particular draw))
        (case (= ?category 1) (table-sample-weighted reading_particulars particular draw))
        (else (table-sample-weighted food_particulars particular draw))))

; ?glass is filled with ?drink: a fluid of that kind, the glass's size, that the glass grips
; (drink.ms2's control).
(define-func fill-glass (?glass ?drink)
  (create-entity ?drink (spatial ?glass bounds /env) /fit): ?fluid
  (spatial-write ?fluid gripped-by ?glass /env))

; The bar-room of ?pub, or @nothing.
(define-func bar-room-of (?pub)
  (bind @nothing ?bar)
  (for-each ?room (spatial (premises-place ?pub) rooms /env)
    (if (is-a ?room [k bar-room])
        (then (bind ?room ?bar) (break))))
  ?bar)

; THE BAR'S STOCK: the glasses each bar-room is authored with, standing full, in place of a
; bartender's service - a man takes one and drinks it. Filled with the town, and every night again
; where a glass stands empty.
(define-func /nightly restock-bars ()
  (for-each ?pub (env-entities [k pub-building])
    (bar-room-of ?pub): ?bar
    (if (substantial ?bar)
        (then
          (for-each ?glass (spatial ?bar contents [k drinking-glass] /env)
            (if (and (empty (spatial ?glass grip /env)) (unsubstantial (spatial ?glass gripped-by /env)))
                (then (fill-glass ?glass (table-sample-weighted drink_particulars particular draw)))))))))

; The drink a glass holds, as @self knows it: the fluid it grips, or @nothing.
(define-func glass-drink (?glass)
  (bind @nothing ?drink)
  (for-each ?held (tolerate (spatial ?glass grip))
    (if (is-a ?held [k fluid])
        (then (bind ?held ?drink) (break))))
  ?drink)

; The man whose hand holds the glass that grips ?fluid, or @nothing.
(define-func drinker-of (?fluid)
  (bind (tolerate (spatial ?fluid gripped-by)) ?glass)
  (flip (substantial ?glass) (tolerate (spatial ?glass held-by)) @nothing))

; The glass ?hand grips, or @nothing.
(define-func glass-in-hand (?hand)
  (bind @nothing ?held)
  (for-each ?thing (tolerate (spatial ?hand grip))
    (if (is-a ?thing [k drinking-glass])
        (then (bind ?thing ?held) (break))))
  ?held)

; The glass ?who holds, or @nothing.
(define-func held-glass (?who)
  (bind (glass-in-hand (spatial ?who right-hand)) ?held)
  (flip (substantial ?held) ?held (glass-in-hand (spatial ?who left-hand))))

; The drinks of a session, and the minutes since the last of them (a day when none yet).
(define-func session-drink-count (?session)
  (count (every {@self DRINK ? /succ /caused_by ?session})))

(define-func minutes-since-session-drink (?session)
  (bind 1440 ?since)
  (for-each ?DRINK (every {@self DRINK ? /succ /caused_by ?session})
    (bind (min ?since (elapsed /minutes ?DRINK)) ?since))
  ?since)

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
