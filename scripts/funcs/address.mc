; ----------------------------------------------------------------------------
; address - how @self speaks of a man by name once the talk has named him and "he" or "she" would not
; do (ruled 2026-11-19): his first name when he is @self's kin or a child, or when @self and the one
; he speaks to are both his friends; else his title and surname, "Mr Brennan", "Mrs Cooper", "Dr
; Dixon". The realizer asks it (the phrasebook's refer: line) and says the answer.
; ----------------------------------------------------------------------------

; (term-of-reference ?person ?listener) - @true for ?person's first name; else the title kind said
; before his surname; @nothing when @self holds nothing to tell which, and his full name is said.
(define-func term-of-reference (?person ?listener)
  (cond (case (or (kin-of ?person) (a-child ?person) (shared-friend ?person ?listener)) @true)
        (else (title-of ?person))))

; ?person is @self's kin: a tie of blood or marriage.
(define-func kin-of (?person)
  (substantial (any {@self parent|mother|father|brother|sister|sibling|half-sibling|grandmother|grandfather|grandparent|grandchild|aunt|uncle|niece|nephew|cousin|mother-in-law|father-in-law|parent-in-law|sister-in-law|brother-in-law|sibling-in-law|daughter-in-law|son-in-law|child-in-law|stepmother|stepfather|stepchild|child|spouse|fiancee ?person})))

; ?person is a child, by his age.
(define-func a-child (?person)
  (substantial (any {?person age-band infant|juvenile|adolescent})))

; @self and ?listener are both friends of ?person.
(define-func shared-friend (?person ?listener)
  (and (substantial (any {@self friend ?person}))
       (substantial (any {?listener friend ?person}))))

; The title said before ?person's surname: his office's - a physician's, a priest's, a constable's -
; else his sex's and, for a woman, whether she is married; @nothing when @self holds neither.
(define-func title-of (?person)
  (bind (any {?person job ?}) ?held)
  (bind (flip (is-belief ?held) ?held.target @nothing) ?job)
  (bind (any {?person gender ?}) ?sex)
  (cond (case (and (is-object ?job) (or (is-a ?job [k physician]) (is-a ?job [k surgeon]))) [k doctor-title])
        (case (and (is-object ?job) (is-a ?job [k priest])) [k reverend-title])
        (case (and (is-object ?job) (is-a ?job [k constable])) [k constable-title])
        (case (not (is-belief ?sex)) @nothing)
        (case (eq ?sex.target [k male]) [k mister-title])
        (case (substantial (any {?person spouse ? /ever})) [k missus-title])
        (else [k miss-title])))
