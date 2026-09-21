; ----------------------------------------------------------------------------
; affair_macros.mc - shared covert-affair effect sequences.
;
; (covert-affair-motive ?paramour): the concealment gate - an affair conducts
; itself covertly only when discovery has a price: a married side, a betrothed
; side, or a cross-class pairing. An open same-class courtship between the
; unattached needs no covert channel. Shared by the correspondence +
; rendezvous conduct rules.
;
; ----------------------------------------------------------------------------

(define-macro covert-affair-motive (?paramour)
  (or {@self spouse @something} {?paramour spouse @something}
      {@self fiancee @something} {?paramour fiancee @something}
      ; cross-class as @self KNOWS it: @self holds a class belief about ?paramour and
      ; it is not @self's own class (telepathy-pure - no read of ?paramour's own mind).
      (and {?paramour class-situation ?}
           -{?paramour class-situation (any {@self class-situation}).target})))


