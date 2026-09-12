; ----------------------------------------------------------------------------
; make-human - mint ONE fully-specified NPC human housed in ?building: pick a room,
; sample appearance / traits / name, create the entity, and seed its self-beliefs
; (home = ?building). Returns the created human (@fail when the building has no room).
; The founder population func loops this; any other caller that needs a single human
; (not a whole population) calls it directly.
;
;   (make-human ?building ?class)  - ?building = the residence the human is housed in,
;                                    ?class = the class situation he is born into.
; ----------------------------------------------------------------------------

(include "human-traits.mc")

(define-func make-human (?building ?class)
  (head (spatial ?building parts [k room] /env)): ?room
  (if ?room
    (then
      (table-sample-weighted gender_dist value weight): ?gender
      (table-sample-weighted nationality_dist value weight): ?nat
      (create-entity [k human] ?room): ?h
      (if ?h
        (then
          (set-attr ?h gender ?gender)
          (set-attr ?h game-role [k nonplayer])
          ; Parentless: both lineage args unsubstantial, so every trait is a fresh
          ; draw on the population distribution (see human-traits.hs).
          (seed-human-genetics ?h ?gender @nothing @nothing)
          (+ (founder_age_min) (random-int 0 (- (founder_age_max) (founder_age_min)))): ?age
          (set-attr ?h birth-date
            (create-date (- (year) ?age) (random-int 0 11) (random-int 0 27)))
          (set-attr ?h name (sample-name ?gender ?nat ?class))
          (seed-human-self-beliefs ?h ?class ?nat ?building)
          ?h)))))

; ----------------------------------------------------------------------------
; seed-human-self-beliefs - the mental layer every human starts life holding: who
; he is (class, nationality, the breeding his class seeds) and where he lives.
; Shared by make-human and the GIVE-BIRTH action, which adds the kin beliefs a
; newborn also carries.
; ----------------------------------------------------------------------------

(define-func seed-human-self-beliefs (?h ?class ?nat ?home)
  (enter-mind ?h)
  ; SEE the home before believing anything about it. A belief field is passively
  ; converted into the believer's own realm, so an object the mind has never met
  ; lands as @fail - you cannot hold a belief about a building you have never laid
  ; eyes on. Observing is the sanctioned way to meet one.
  (observe ?home)
  (begin-belief {@self class-situation ?class})
  (begin-belief {@self nationality ?nat})
  (begin-belief {@self breeding (breeding-for-class ?class)})
  (begin-belief {@self home ?home})
  (begin-belief {@self interest (random-subkind [k domain])})
  (begin-belief {@self interest (random-subkind [k domain])})
  (begin-belief {@self interest (random-subkind [k domain])})
  (exit-mind))

; ----------------------------------------------------------------------------
; class-for-residence - the class a founder is born into, read off the residence he
; heads. The house IS the class marker in 1700: a manor seats gentry, a townhouse the
; middle, and everything else that people live in (rowhouse / farmhouse / chapel) the
; working class. This is what spreads founders across the class floors the public_orgs
; and cornerstone_businesses tables gate on - a town of nothing but townhouse-dwellers
; can seat neither an upper-class hospital nor a lower-class registry.
; ----------------------------------------------------------------------------

(define-func class-for-residence (?b)
  (if (is-a ?b [k building manor])
    (then [k upper])
    (else
      (if (is-a ?b [k building townhouse])
        (then [k middle])
        (else [k lower])))))

; ----------------------------------------------------------------------------
; make-human-founder - the world-gen founder population: one adult per RESIDENTIAL
; building, each minted by (make-human) with the class his residence implies.
; Commercial buildings house nobody, so they are not walked at all. Invoked ONCE at
; populate.
; ----------------------------------------------------------------------------

(define-func make-human-founder ()
  (for-each ?b (env-entities [k building residential-building])
    (if (chance (founder_density)) (make-human ?b (class-for-residence ?b)))))
