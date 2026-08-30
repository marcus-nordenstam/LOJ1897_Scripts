; ----------------------------------------------------------------------------
; make-human - mint ONE fully-specified NPC human housed in ?building: pick a room,
; sample appearance / traits / name, create the entity, and seed its self-beliefs
; (home = ?building). Returns the created human (@fail when the building has no room).
; The founder population func loops this; any other caller that needs a single human
; (not a whole population) calls it directly.
;
;   (make-human ?building)  - ?building = the residence the human is housed in.
; ----------------------------------------------------------------------------

(define-func make-human (?building)
  (head (spatial ?building parts [k room] /env)): ?room
  (if ?room
    (then
      (table-sample-weighted gender_dist value weight): ?gender
      (table-sample-weighted nationality_dist value weight): ?nat
      (create-entity [k human] ?room): ?h
      (if ?h
        (then
          (set-attr ?h gender ?gender)
          (set-attr ?h game_role [k nonplayer])
          (set-attr ?h appearance (table-sample-weighted appearance_dist value weight))
          (set-attr ?h girth      (table-sample-weighted girth_dist value weight))
          (set-attr ?h height     (table-sample-weighted height_dist value weight))
          (set-attr ?h hair_color (table-sample-weighted hair_color_dist value weight))
          (set-attr ?h eye_color  (table-sample-weighted eye_color_dist value weight))
          (for-each-row continuous_traits
              (trait ?t) (mean_male ?mm) (mean_female ?mf) (sigma ?sg)
            (if (= ?gender [k male]) (then ?mm) (else ?mf)): ?mean
            (set-attr ?h ?t (clamp (sample-gaussian ?mean ?sg) 0 1)))
          (+ 20 (random-int 0 29)): ?age
          (set-attr ?h birth_date
            (create-date (- (year) ?age) (random-int 0 11) (random-int 0 27)))
          (set-attr ?h name (sample-name ?gender ?nat [k middle]))
          (enter-mind ?h)
          (begin-belief {@self class_situation [k middle]})
          (begin-belief {@self nationality ?nat})
          (begin-belief {@self breeding 0.55})
          (begin-belief {@self home ?building})
          (begin-belief {@self interest (random-subkind [k domain])})
          (begin-belief {@self interest (random-subkind [k domain])})
          (begin-belief {@self interest (random-subkind [k domain])})
          (exit-mind)
          ?h)))))

; ----------------------------------------------------------------------------
; make-human-founder - the world-gen founder population: one adult per residential
; building (capped), each minted by (make-human). Invoked ONCE at populate.
; ----------------------------------------------------------------------------

(define-func make-human-founder ()
  (for-each ?b (env-entities [k building]) 5
    (make-human ?b)))
