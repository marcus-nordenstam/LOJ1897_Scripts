; ----------------------------------------------------------------------------
; Adult friendships. Lower per-person rate than childhood - adults make
; friends less often once kin / work / marriage already structure their
; social orbit. Once a year in september.
;
; Topology: ?a enumerated; ?b sampled from same-class adults within 10
; years of age who are not already ?a's friend.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event adult_friendship
  (nl         "?a and ?b become friends")
  (kind       _friendship)
  (schedule   (annually september))
  (rng-stream friendships)

  (roles
    ; High enthusiasm (the sociable Extraversion aspect) makes friends more
    ; readily. Mean-1.0 multiplier - friendship volume is unchanged.
    ; A scandalous reputation closes the social door - no new friendships
    ; form on either side (the existing friend beliefs are ended by the
    ; social_ostracism event when the situation falls).
    (role ?a (template any_human)
             (>= (years-old ?self) 18)
             (not (= (situation ?self respectability_situation) scandalous))
             (chance (* 0.05 (+ 0.5 (attr ?self enthusiasm)))))
    (role ?b (template any_human)
             (>= (years-old ?self) 18)
             (not (= ?self ?a))
             (not (= (situation ?self respectability_situation) scandalous))
             (= (situation ?self class_situation) (situation ?a class_situation))
             (<= (- (years-old ?self) (years-old ?a))  10)
             (>= (- (years-old ?self) (years-old ?a)) -10)
             (not (believes ?a {@self friend ?b}))))

  (effects
    (begin-belief        ?a friend ?b)
    (begin-belief        ?b friend ?a)
    (believe-about ?a ?b)
    (believe-about ?b ?a)
    (log _friendship ?a)))
