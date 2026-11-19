; ----------------------------------------------------------------------------
; address - how @self speaks of a man by name once the talk has named him and "he" or "she" would not
; do (ruled 2026-11-19): his first name when he is @self's kin or a child, or when @self and the one
; he speaks to are both his friends; else his title and surname, "Mr Brennan", "Mrs Cooper", "Dr
; Dixon". The realizer asks it (the phrasebook's refer: line) and says the answer.
; ----------------------------------------------------------------------------

; (term-of-reference ?person ?listener) - @true for ?person's first name; else the title kind said
; before his name (name-after-title); @nothing when @self holds nothing to tell which, and his full
; name is said. Kin are named by their first names whatever they hold; a title the crown gave, or
; one a peer's child bears, comes before a child's first name.
(define-func term-of-reference (?person ?listener)
  (bind (honour-title ?person) ?honour)
  (cond (case (kin-of ?person) @true)
        (case (substantial ?honour) ?honour)
        (case (or (a-child ?person) (shared-friend ?person ?listener)) @true)
        (else (title-of ?person))))

; (name-after-title ?person ?title) - the word @self says after ?title for ?person: his first name
; after Sir, or as a peer's child; his peerage's name, or his husband's, after a peer's title; else
; @nothing, and his surname is said.
(define-func name-after-title (?person ?title)
  (bind (any {?person name ?}) ?named)
  (bind (flip (is-belief ?named) ?named.target @nothing) ?name)
  (bind (peerage-of ?person) ?peerage)
  (cond (case (and (eq ?title [k sir-title]) (substantial ?name)) (name-part /first ?name))
        (case (substantial ?peerage) ?peerage)
        (case (and (substantial (ranked-father ?person)) (substantial ?name)) (name-part /first ?name))
        (else @nothing)))

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

; The honour ?person holds, else her husband's, as @self holds them.
(define-func honour-of (?person)
  (bind (any {?person honour ?}) ?own)
  (bind (any {?person spouse ?}) ?married)
  (bind (flip (is-belief ?married) (any {?married.target honour ?}) @nothing) ?his)
  (cond (case (is-belief ?own) ?own.target)
        (case (is-belief ?his) ?his.target)
        (else @nothing)))

; The name of the peerage ?person holds, else her husband's; @nothing for none.
(define-func peerage-of (?person)
  (bind (any {?person peerage ?}) ?own)
  (bind (any {?person spouse ?}) ?married)
  (bind (flip (is-belief ?married) (any {?married.target peerage ?}) @nothing) ?his)
  (cond (case (is-belief ?own) ?own.target)
        (case (is-belief ?his) ?his.target)
        (else @nothing)))

; ?person's father's honour when it gives his children a title of their own - a duke's or a
; marquess's sons and daughters, an earl's daughters; @nothing else.
(define-func ranked-father (?person)
  (bind (any {?person father ?}) ?fathered)
  (bind (flip (is-belief ?fathered) (any {?fathered.target honour ?}) @nothing) ?his)
  (bind (flip (is-belief ?his) ?his.target @nothing) ?honour)
  (bind (female ?person) ?daughter)
  (cond (case (or (eq ?honour [k duke]) (eq ?honour [k marquess])) ?honour)
        (case (and ?daughter (eq ?honour [k earl])) ?honour)
        (else @nothing)))

; ?person is held a woman.
(define-func female (?person)
  (bind (any {?person gender ?}) ?sex)
  (and (is-belief ?sex) (eq ?sex.target [k female])))

; The title the crown's honour gives ?person, or a peer's child bears: Sir for a knight or baronet,
; Lord for a peer, the Duke of for a duke; their wives Lady, the Duchess of; a duke's or marquess's
; son Lord, and his or an earl's daughter Lady. @nothing for none.
(define-func honour-title (?person)
  (bind (honour-of ?person) ?honour)
  (bind (female ?person) ?woman)
  (bind (ranked-father ?person) ?father)
  (cond (case (eq ?honour [k duke]) (flip ?woman [k duchess-title] [k duke-title]))
        (case (or (eq ?honour [k knight]) (eq ?honour [k baronet])) (flip ?woman [k lady-title] [k sir-title]))
        (case (substantial ?honour) (flip ?woman [k lady-title] [k lord-title]))
        (case (substantial ?father) (flip ?woman [k lady-title] [k lord-title]))
        (else @nothing)))

; The title said before ?person's surname: his office's - a physician's Dr, a priest's the Reverend
; Mr, a constable's, a professor's, an officer's rank - else his sex's and, for a woman, whether she
; is married; @nothing when @self holds neither. A surgeon is Mr, as English surgeons are.
(define-func title-of (?person)
  (bind (any {?person job ?}) ?held)
  (bind (flip (is-belief ?held) ?held.target @nothing) ?job)
  (bind (any {?person army-rank ?}) ?ranked)
  (bind (flip (is-belief ?ranked) ?ranked.target @nothing) ?rank)
  (bind (any {?person gender ?}) ?sex)
  (cond (case (and (is-object ?job) (is-a ?job [k physician])) [k doctor-title])
        (case (and (is-object ?job) (is-a ?job [k priest])) [k reverend-title])
        (case (and (is-object ?job) (is-a ?job [k constable])) [k constable-title])
        (case (and (is-object ?job) (is-a ?job [k professor])) [k professor-title])
        (case (eq ?rank [k colonel]) [k colonel-title])
        (case (eq ?rank [k major]) [k major-title])
        (case (eq ?rank [k captain]) [k captain-title])
        (case (not (is-belief ?sex)) @nothing)
        (case (eq ?sex.target [k male]) [k mister-title])
        (case (substantial (any {?person spouse ? /ever})) [k missus-title])
        (else [k miss-title])))
