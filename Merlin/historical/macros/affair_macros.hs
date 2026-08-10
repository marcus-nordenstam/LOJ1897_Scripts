; ----------------------------------------------------------------------------
; affair_macros.hs - shared covert-affair effect sequences.
;
; (covert-affair-motive ?paramour): the concealment gate - an affair conducts
; itself covertly only when discovery has a price: a married side, a betrothed
; side, or a cross-class pairing. An open same-class courtship between the
; unattached needs no covert channel. Shared by the correspondence +
; rendezvous conduct events.
;
; ----------------------------------------------------------------------------

(define-macro covert-affair-motive (?paramour)
  (or (is-married @self) (is-married ?paramour)
      (is-betrothed @self) (is-betrothed ?paramour)
      ; cross-class as @self KNOWS it: @self holds a class belief about ?paramour and
      ; it is not @self's own class (telepathy-pure - no read of ?paramour's own mind).
      (and (believes {?paramour class_situation ?})
           (none {?paramour class_situation (target {@self class_situation})}))))

; Route one covert letter with the authored channel model (tunables.hs). The
; ONE way content should call the routing verb - the C++ carries no defaults.
(define-macro send-covert-letter (?to ?msg ?kind)
  (route-covert-letter ?to ?msg ?kind
    /w-courier          (covert_w_courier)
    /w-post             (covert_w_post)
    /w-poste            (covert_w_poste)
    /intercept-courier  (covert_intercept_courier)
    /intercept-post     (covert_intercept_post)
    /dislike-gain       (covert_dislike_gain)
    /suspicion-gain     (covert_suspicion_gain)
    /intercept-cap      (covert_intercept_cap)
    /handling-suspicion (covert_handling_suspicion)))
