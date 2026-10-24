; What a band is worth as virtue, on every banded dimension.
(define-table band_virtue (fields band virtue)
  (record [k good]      0.85)
  (record [k fair]      0.65)
  (record [k lax]       0.25)
  (record [k devout]    0.85)
  (record [k observant] 0.65)
  (record [k secular]   0.25))

; The virtue of the band ?who holds on ?dim, ?unknown when he holds none.
(define-func band-virtue (?who ?dim ?unknown)
  (any {?who ?dim ?band=@nothing})
  (bind ?unknown ?virtue)
  (for-each-row band_virtue [/band ?held] [/virtue ?worth]
    (if (= ?band ?held) (then (bind ?worth ?virtue) (break))))
  ?virtue)

; repute-fold - the seven-term mean the repute band-cut reads, for @self or ?other.
(define-func repute-fold (?who)
  (any {?who decorum ?decorum=(unknown-band-virtue)})
  (bind (count (every {?who lover ? /ever})) ?liaisons)
  (/ (+ (band-virtue ?who honesty (unknown-band-virtue))
        (band-virtue ?who diligence (unknown-band-virtue))
        (band-virtue ?who generosity (unknown-band-virtue))
        (band-virtue ?who sobriety (unknown-band-virtue))
        (band-virtue ?who piety (unknown-band-virtue))
        ?decorum
        (- 0.85 (* (>= ?liaisons 1) 0.30)
                (* (>= ?liaisons 2) 0.30))) 7.0))
