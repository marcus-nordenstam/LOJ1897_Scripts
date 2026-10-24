; ----------------------------------------------------------------------------
; education_macros.mc - the schooling tunables.
;
; A pupil's industriousness and intellect fall into a band (0 low, 1 middle, 2 high) at
; these edges when his grade is rolled from the school_grades table (tables/school-grades.mc).
; ----------------------------------------------------------------------------

(define-macro school-band-low-edge () 0.4)
(define-macro school-band-high-edge () 0.6)
