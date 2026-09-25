; ----------------------------------------------------------------------------
; make-human - mint ONE fully-specified NPC human housed in ?building: pick a room,
; sample appearance / traits / name, create the entity, and seed its self-beliefs
; (home = ?building). Returns the created human (@fail when the building has no room).
;
;   (make-human ?building ?class ?gender)
;
; The gender is the CALLER's, not a roll made in here: a founder household needs one
; of each, and a rule that rolled its own could not ask for that. A caller with no
; stake in it draws (table-sample-weighted gender_dist value weight) and passes it.
; ----------------------------------------------------------------------------

(include "human-traits.mc")
(include "age.mc")

(define-func make-human (?building ?class ?gender)
  (head (spatial ?building parts [k room] /env)): ?room
  (check ?room)
  (if ?room
    (then
      (table-sample-weighted nationality_dist value weight): ?nat
      (create-entity [k human] ?room): ?h
      (check ?h)
      (if ?h
        (then
          (set-attr ?h gender ?gender)
          (set-attr ?h game-role [k nonplayer])
          ; Parentless: both lineage args unsubstantial, so every trait is a fresh
          ; draw on the population distribution (see human-traits.mc).
          (seed-human-genetics ?h ?gender @nothing @nothing)
          (seed-human-vitals ?h)
          (seed-npc-habits ?h)
          (set-attr ?h parentless 1)
          (+ (founder_age_min) (random-int 0 (- (founder_age_max) (founder_age_min)))): ?age
          (set-attr ?h birth-date
            (create-date (- (time year) ?age) (random-int 0 11) (random-int 0 27)))
          (set-attr ?h name (sample-name ?gender ?nat ?class))
          (start-aging ?h)
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
  (observe ?home): ?known-home
  (begin-belief {@self class-situation ?class})
  (begin-belief {@self nationality ?nat})
  (begin-belief {@self breeding (breeding-for-class ?class)})
  ; The OBSERVED object, not the raw abs one: a place field left to convert itself
  ; passively lands as the building's ADDRESS - the universal place reference - and
  ; an address is a value, not an object. A home is a BUILDING, so every reader that
  ; asks the home for its rooms, or mints a belief about it, needs the object.
  (begin-belief {@self home ?known-home})
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
  (switch (kind ?b)
    (on [k building manor]     [k upper])
    (on [k building townhouse] [k middle])
    (else [k lower])))

; ----------------------------------------------------------------------------
; make-founder-household - one COUPLE per residence, man and woman. Never a
; single: a parish of people living one to a house has no co-presence in it, and
; without co-presence nothing social can start - no conception, no introduction,
; no affair, since every one of those gates on two people being in the same place.
; Both are minted into the same building (make-human seats them in its first
; room), so they begin life under one roof and in one another's sight.
;
; They are not WED here. A marriage is a belief each spouse holds about the other,
; and at populate no mind has been self-perceived yet - a human simply cannot be
; the target of another mind's belief at that point (it lands @fail, and the
; conversion ops either fail or take the sim down). The wedding is therefore a
; (startup) rung - wed_at_founding - which runs once minds are live and each
; spouse mints their own half.
; ----------------------------------------------------------------------------

(define-func make-founder-household (?building ?class)
  (make-human ?building ?class [k male]): ?husband
  (make-human ?building ?class [k female]): ?wife
  ?husband)

; ----------------------------------------------------------------------------
; make-human-founder - the world-gen founder population: one household per
; RESIDENTIAL building, each with the class its residence implies. Commercial
; buildings house nobody, so they are not walked at all. Called ONCE by town-startup.
; ----------------------------------------------------------------------------

(define-func make-human-founder ()
  (for-each ?b (env-entities [k building residential-building])
    (if (chance (founder_density)) (make-founder-household ?b (class-for-residence ?b)))))
