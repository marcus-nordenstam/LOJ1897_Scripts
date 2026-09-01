; ----------------------------------------------------------------------------
; foundable-orgs.hs - the catalogs an NPC founding a concern draws from. One row
; per foundable kind; `weight` biases the draw. Nothing here gates on premises:
; found-org-seq's own (if ?wp) guard no-ops a founding with nowhere to house it,
; so a kind with no free building simply produces nothing that trip.
; ----------------------------------------------------------------------------

(define-table foundable_businesses
  (fields kind weight)
  (record [k org grocer]        1)
  (record [k org bookseller]    1)
  (record [k org barbershop]    1)
  (record [k org restaurant]    1)
  (record [k org pawnbroker]    1)
  (record [k org apothecary]    1)
  (record [k org antiques-shop] 1)
  (record [k org hotel]         1))

(define-table foundable_clubs
  (fields kind weight)
  (record [k org race-club]     1)
  (record [k org athletic-club] 1))
