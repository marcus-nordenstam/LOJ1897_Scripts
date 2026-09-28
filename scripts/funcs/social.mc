; Does the deliberator believe ?p keeps a THIRD-PARTY lover: more known lover
; bonds than the benign ones (@self, and ?p's own spouse - stale courtship
; gossip can name either) - the surplus IS an interloper.
(define-func partner-keeps-interloper (?p)
  (any {?p spouse ?spouse=@nothing})
  (> (count (every {?p lover ?}))
     (+ (count (every {?p lover @self}))
        (if (substantial ?spouse) (then (count (every {?p lover ?spouse}))) (else 0)))))

; Does the deliberator believe his own spouse or lover keeps an interloper?
(define-func knows-affair ()
  (any {@self spouse ?spouse=@nothing})
  (any {@self lover ?lover=@nothing})
  (or (and (substantial ?spouse) (partner-keeps-interloper ?spouse))
      (and (substantial ?lover) (partner-keeps-interloper ?lover))))

; Is the deliberator's spouse in the room with him? The unmarried have none to be.
(define-func spouse-co-located ()
  (any {@self spouse ?spouse=@nothing})
  (and (substantial ?spouse) (spatial ?spouse co-located @self)))
