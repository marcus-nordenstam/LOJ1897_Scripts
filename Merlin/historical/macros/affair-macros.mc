; ----------------------------------------------------------------------------
; affair_macros.hs - shared covert-affair effect sequences.
;
; (covert-affair-motive ?paramour): the concealment gate - an affair conducts
; itself covertly only when discovery has a price: a married side, a betrothed
; side, or a cross-class pairing. An open same-class courtship between the
; unattached needs no covert channel. Shared by the correspondence +
; rendezvous conduct rules.
;
; ----------------------------------------------------------------------------

(define-macro covert-affair-motive (?paramour)
  (or (is-married @self) (is-married ?paramour)
      (is-betrothed @self) (is-betrothed ?paramour)
      ; cross-class as @self KNOWS it: @self holds a class belief about ?paramour and
      ; it is not @self's own class (telepathy-pure - no read of ?paramour's own mind).
      (and {?paramour class-situation ?}
           -{?paramour class-situation (any {@self class-situation}).target})))

; Route one covert letter with the authored channel model (tunables.hs). The
; ONE way content should call the routing verb - the C++ carries no defaults.
; The covert channel model (courier / post / poste-restante, interception rolls, and
; the dislike + suspicion the interception costs) has no substrate: the channel choice
; and the interception are unauthored, and the two gains write OTHER minds. For now the
; letter goes by the ordinary post - visible, interceptable by whoever handles it, and
; honest - with the covert routing left to the redesign.
(define-macro send-covert-letter (?to ?msg ?kind)
  (post-letter ?kind ?msg (any {?to home ?}).target ?to))
