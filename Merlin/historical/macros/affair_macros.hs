; ----------------------------------------------------------------------------
; affair_macros.hs - shared covert-affair effect sequences.
;
; (covert-affair-motive ?paramour): the concealment gate - an affair conducts
; itself covertly only when discovery has a price: a married side, a betrothed
; side, or a cross-class pairing. An open same-class courtship between the
; unattached needs no covert channel. Shared by the correspondence +
; rendezvous conduct events.
;
; (tryst-tail ?paramour ?location): what EVERY consummated meeting leaves
; behind, whatever the mode - the mutual attraction nudge, the consummation
; roll's reciprocal punctual HAVE_SEX_WITH act-records (what the chastity
; classifiers count once they leak), the optional hand-delivered tryst_note
; naming the place (no interception surface; cached as detective paper at the
; paramour's home), and the paramour's spouse's unexplained-absence suspicion
; tick. The ACTOR-side absence tick stays with the caller - a hotel excursion
; explains the actor's absence (the spouse was co-present), the other modes do
; not.
; ----------------------------------------------------------------------------

(define-macro covert-affair-motive (?paramour)
  (or (is-married @self) (is-married ?paramour)
      (is-betrothed @self) (is-betrothed ?paramour)
      ; cross-class as @self KNOWS it: @self holds a class belief about ?paramour and
      ; it is not @self's own class (telepathy-pure - no read of ?paramour's own mind).
      (and (believes {?paramour class_situation ?})
           (not (believes {?paramour class_situation (target {@self class_situation})})))))

(define-macro tryst-tail (?paramour ?location)
  (do
    ; The meeting advances the affair on both sides.
    (nudge-stance @self ?paramour attraction 0.10)
    (nudge-stance ?paramour @self attraction 0.10)
    ; Consummation: not every affair is sexual.
    (if (chance 0.60)
        (then
          (begin-ended-belief {@self HAVE_SEX_WITH ?paramour})
          (begin-ended-belief ?paramour {?paramour HAVE_SEX_WITH @self})))
    ; The hand-to-hand note naming the place (the aux is the 4th positional
    ; pattern field: {@self meet <paramour> <location>}).
    (if (and (chance 0.30) (is-entity (home-of ?paramour)))
        (then (spawn-letter [k tryst_note]
                      (written-msg {@self meet ?paramour ?location} signed)
                      (home-of ?paramour))))
    ; Unexplained absence: the paramour's spouse grows a little more suspicious.
    (bump-suspicion (spouse-of ?paramour) ?paramour 0.05)))

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
