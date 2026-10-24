; ----------------------------------------------------------------------------
; school-grades.mc - the letter grade a pupil leaves a school with, weighted by the
; school tier and two bands of the pupil: industriousness and intellect (0 low, 1 middle,
; 2 high - the band edges are macros in macros/education-macros.mc). Each row holds the
; A..F weights; graduation rolls one grade against them. The weights are placeholders.
; ----------------------------------------------------------------------------

(define-table school_grades
  (fields tier industry intellect a b c d f)
  (record [k primary-school-curriculum] 0 0 5 30 30 15 20)
  (record [k primary-school-curriculum] 0 1 15 30 30 15 10)
  (record [k primary-school-curriculum] 0 2 25 30 30 15 0)
  (record [k primary-school-curriculum] 1 0 10 30 30 15 15)
  (record [k primary-school-curriculum] 1 1 20 30 30 15 5)
  (record [k primary-school-curriculum] 1 2 30 30 30 10 0)
  (record [k primary-school-curriculum] 2 0 15 30 30 15 10)
  (record [k primary-school-curriculum] 2 1 25 30 30 15 0)
  (record [k primary-school-curriculum] 2 2 35 30 30 5 0)
  (record [k secondary-school-curriculum] 0 0 0 25 30 20 25)
  (record [k secondary-school-curriculum] 0 1 10 25 30 20 15)
  (record [k secondary-school-curriculum] 0 2 20 25 30 20 5)
  (record [k secondary-school-curriculum] 1 0 5 25 30 20 20)
  (record [k secondary-school-curriculum] 1 1 15 25 30 20 10)
  (record [k secondary-school-curriculum] 1 2 25 25 30 20 0)
  (record [k secondary-school-curriculum] 2 0 10 25 30 20 15)
  (record [k secondary-school-curriculum] 2 1 20 25 30 20 5)
  (record [k secondary-school-curriculum] 2 2 30 25 30 15 0)
  (record [k academic-field] 0 0 0 20 30 22 28)
  (record [k academic-field] 0 1 5 25 30 22 18)
  (record [k academic-field] 0 2 15 25 30 22 8)
  (record [k academic-field] 1 0 0 25 30 22 23)
  (record [k academic-field] 1 1 10 25 30 22 13)
  (record [k academic-field] 1 2 20 25 30 22 3)
  (record [k academic-field] 2 0 5 25 30 22 18)
  (record [k academic-field] 2 1 15 25 30 22 8)
  (record [k academic-field] 2 2 25 25 30 20 0))
