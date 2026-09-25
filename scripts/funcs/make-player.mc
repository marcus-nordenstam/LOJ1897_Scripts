; ----------------------------------------------------------------------------
; humanize-player - everything make-human does to a human EXCEPT mint it.
;
; The player's env entity is minted by the ENGINE, not here: only make_entity can
; route an entity into the player population, and that population choice cannot be
; changed afterwards. So the layer that turns that bare entity into a PERSON - sex,
; age, name, the genetic profile every NPC reads off him - is called on it after the
; fact, with the gender the player's own .spawn already fixed by choosing his body.
;
; No self-beliefs: seed-human-self-beliefs enters the subject's mind, and the player
; is not sentient - he carries no mind to hold them. What he needs is the PERCEIVABLE
; layer, which is exactly the attrs below.
;
; ?female is a 0/1 flag, not a kind: the engine knows only which body the player's
; .spawn picked, and every world term the answer implies - the gender kinds, the class
; he is taken for - is named HERE, where world terms belong.
; ----------------------------------------------------------------------------

(include "human-traits.mc")
(include "age.mc")

(define-func humanize-player (?p ?female)
  (check ?p)
  (if ?p
    (then
      (if (= ?female 1) (then [k female]) (else [k male])): ?gender
      (bind [k middle] ?class)
      (table-sample-weighted nationality_dist value weight): ?nat
      (set-attr ?p gender ?gender)
      (set-attr ?p game-role [k player])
      (seed-human-genetics ?p ?gender @nothing @nothing)
      (seed-human-vitals ?p)
      (+ (founder_age_min) (random-int 0 (- (founder_age_max) (founder_age_min)))): ?age
      (set-attr ?p birth-date
        (create-date (- (time year) ?age) (random-int 1 12) (random-int 1 28)))
      (set-attr ?p name (sample-name ?gender ?nat ?class))
      (start-aging ?p)
      ?p)))
