; ----------------------------------------------------------------------------
; name-gives-gender (reflex) - a man learns a human's name and takes the gender it gives him: John
; is a man. Nothing is minted for one whose gender he already holds, or whose first name's pool
; declares none (ontology (name-gender ..)).
; ----------------------------------------------------------------------------

(reflex {?person name ?name}
  (when (and (dirty-born)
             (is-a ?person [k human])
             (unsubstantial (any {?person gender ?}))))
  (effects
    (bind (name-gender ?name) ?gender)
    (if (substantial ?gender)
        (then (begin-belief {?person gender ?gender})))))
