; A trait value's band for the school_grades table: 0 low, 1 middle, 2 high.
(define-func school-band (?value)
  (flip (< ?value (school-band-low-edge)) 0 (flip (> ?value (school-band-high-edge)) 2 1)))

; The school_grades tier a studied curriculum belongs to: primary, secondary, or a university
; discipline (any academic field).
(define-func school-tier (?curriculum)
  (flip (is-a ?curriculum [k primary-school-curriculum]) [k primary-school-curriculum]
        (flip (is-a ?curriculum [k secondary-school-curriculum]) [k secondary-school-curriculum]
              [k academic-field])))

; The letter grade @self leaves ?curriculum with, rolled against the school_grades row for its
; tier and his industriousness and intellect bands.
(define-func school-grade (?curriculum)
  (bind (school-band (any {@self industriousness ?}).target) ?sg-industry)
  (bind (school-band (any {@self intellect ?}).target) ?sg-intellect)
  (table-match school_grades tier (school-tier ?curriculum) industry ?sg-industry intellect ?sg-intellect
               a ?sg-a b ?sg-b c ?sg-c d ?sg-d f ?sg-f)
  (bind (random-int 1 (+ ?sg-a ?sg-b ?sg-c ?sg-d ?sg-f)) ?sg-roll)
  (flip (<= ?sg-roll ?sg-a) [k A]
        (flip (<= ?sg-roll (+ ?sg-a ?sg-b)) [k B]
              (flip (<= ?sg-roll (+ ?sg-a ?sg-b ?sg-c)) [k C]
                    (flip (<= ?sg-roll (+ ?sg-a ?sg-b ?sg-c ?sg-d)) [k D] [k F])))))

; graduate-from-study - end each ongoing {@self study <curriculum>} (unforgettable, so the
; schooling years survive as history) and mint the {@self school-grades <curriculum> <grade>}
; credential. A university discipline also kindles a standing interest. No-op when not enrolled.
(define-func graduate-from-study ()
  (for-each ?study (every {@self study ?})
    (bind ?study.target ?curriculum)
    (if (is-kind ?curriculum)
        (then
          (end-belief {@self study ?curriculum} [/salience unforgettable])
          (begin-belief {@self school-grades ?curriculum (school-grade ?curriculum)})
          (if (= (school-tier ?curriculum) [k academic-field])
              (then (begin-belief {@self interest ?curriculum})))))))
