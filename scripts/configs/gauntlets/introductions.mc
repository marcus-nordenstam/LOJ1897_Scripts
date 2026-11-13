; ----------------------------------------------------------------------------
; introductions - a mother at term with her infant child beside her, at home with her husband.
; She bears the child and christens it, and the birth makes it her intent to introduce the newborn
; and her elder child to each other: said to both at once, each pointed out to the other, the elder
; comes to hold the newborn as a brother or sister. The funcs are written once here and included by
; introductions-jump.mc and introductions-real.mc.
; ----------------------------------------------------------------------------

(include "movement.mc")

; ?child is ?mother's and ?father's, born ?years ago: each holds the bond he stands in, and his
; mother knows his name.
(define-func introductions-make-child (?home ?mother ?father ?years)
  (table-sample-weighted gender_dist value weight): ?gender
  (make-human ?home [k lower] ?gender): ?child
  (set-attr ?child parentless 0)
  (set-attr ?child birth-date (create-date (- (time year) ?years) (time month) (time day)))
  (refresh-age ?child)
  (enter-mind ?child)
  (begin-belief {@self mother (observe ?mother)})
  (begin-belief {@self father (observe ?father)})
  (exit-mind)
  (enter-mind ?mother)
  (observe ?child): ?known-child
  (begin-belief {@self (kin-label child ?gender) ?known-child})
  (begin-belief {?known-child name (attr ?child name)})
  (exit-mind)
  ?child)

; ?mother has carried ?father's child a full year: the child is due.
(define-func introductions-at-term (?mother ?father)
  (set-attr ?mother pregnant-when (create-date (- (time year) 1) (time month) (time day)))
  (set-attr ?mother pregnant-by ?father)
  (enter-mind ?mother)
  (begin-belief {@self pregnant (observe ?father)})
  (exit-mind))

(define-func introductions-startup ()
  (seed_property)
  (spatial (head (env-entities [k pub-building])) space /env): ?town
  (movement-nth-home ?town 0): ?home
  (make-human ?home [k lower] [k male]): ?father
  (make-human ?home [k lower] [k female]): ?mother
  (cast mother ?mother)
  (introductions-make-child ?home ?mother ?father 1): ?elder
  (cast elder ?elder)
  (introductions-at-term ?mother ?father)
  (initialize-minds))

; Every child @self holds hers is one she knows by name.
(define-func introductions-children-named ()
  (bind @true ?named)
  (for-each ?bore (every {@self child ?})
    (if (unsubstantial (name ?bore.target)) (then (bind @false ?named))))
  ?named)

(define-func introductions-validate ()
  (cast mother): ?mother
  (cast elder): ?elder
  (expect (> (acts ?mother give-birth succ) 0) "mother: never gave birth")
  (expect (in-mind ?mother (= (count (every {@self child ?})) 2)) "mother: does not hold the newborn hers")
  (expect (in-mind ?mother (introductions-children-named)) "mother: does not know her newborn's name")
  (expect (> (acts ?mother introduce succ) 0) "mother: never introduced the newborn")
  (expect (in-mind ?elder (substantial (any {@self sibling ?})))
          "elder: holds no brother or sister"))
