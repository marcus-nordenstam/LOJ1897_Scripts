(define-func make-human-founder ()
  (for-each ?b (env-entities [k building]) 5
    (head (spatial ?b parts [k room] /env)): ?room
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
            (begin-belief {@self interest (random-subkind [k domain])})
            (begin-belief {@self interest (random-subkind [k domain])})
            (begin-belief {@self interest (random-subkind [k domain])})
            (exit-mind)))))))
