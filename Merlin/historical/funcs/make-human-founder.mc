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
          (set-attr ?h appearance (table-sample-weighted appearance_dist value weight))
          (set-attr ?h girth      (table-sample-weighted girth_dist value weight))
          (set-attr ?h height     (table-sample-weighted height_dist value weight))
          (set-attr ?h hair-color (table-sample-weighted hair_color_dist value weight))
          (set-attr ?h eye-color  (table-sample-weighted eye_color_dist value weight))
          (for-each-row continuous_traits
              [/trait ?t] [/mean-male ?mm] [/mean-female ?mf] [/sigma ?sg]
            (if (= ?gender [k male]) (then ?mm) (else ?mf)): ?mean
            (set-attr ?h ?t (clamp (sample-gaussian ?mean ?sg) 0 1)))
          (+ 20 (random-int 0 29)): ?age
          (set-attr ?h birth-date
            (create-date (- (year) ?age) (random-int 0 11) (random-int 0 27)))
          (set-attr ?h name (sample-name ?gender ?nat ?class))
          (enter-mind ?h)
          ; SEE the home before believing anything about it. A belief field is passively
          ; converted into the believer's own realm, so an object the mind has never met
          ; lands as @fail - you cannot hold a belief about a building you have never laid
          ; eyes on. Observing is the sanctioned way to meet one.
          (observe ?building)
          (begin-belief {@self class-situation ?class})
          (begin-belief {@self nationality ?nat})
          (begin-belief {@self breeding 0.55})
          (begin-belief {@self home ?building})
          (begin-belief {@self interest (random-subkind [k domain])})
          (begin-belief {@self interest (random-subkind [k domain])})
          (begin-belief {@self interest (random-subkind [k domain])})
          (exit-mind)
          ?h)))))

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
    (if (chance 0.2)
      (make-human ?b (class-for-residence ?b)))))
