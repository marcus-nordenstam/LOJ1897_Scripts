; ----------------------------------------------------------------------------
; vow-realized / spouse-reciprocate reconcile the marriage beliefs the vow makes -
; they gate on fiancee / spouse, not on any attend token, so they stay here.
; ----------------------------------------------------------------------------

; An occasion's day gone by unattended: the obligation lapses and strains @self over the missed
; occasion, the strain caused by its date, which he still remembers.
(think attendance-lapsed
  (role ?occ {?occ held-on ?held-on}:?date
             {@self obligation {@self attend ?occ} ?}
    (when (date-before-today ?held-on))
    (effects
      (any {@self obligation {@self attend ?occ} ?}): ?obligation
      (mint-pressure-caused [k obligation-strain] ?occ 336.0 ?date)
      (end-belief ?obligation))))

; An occasion whose day has passed is organized no more.
(think organize-lapsed
  (role ?occ {@self organize ?occ}
             {?occ held-on ?held-on}
    (when (date-before-today ?held-on))
    (effects (end-belief {@self organize ?occ}))))

(think vow-realized
  (role ?betrothed {@self fiancee ?betrothed}
                   {@self spouse ?betrothed}
    (effects
      (end-belief {@self fiancee ?betrothed})
      ; TELEPATHY - this married both parties by writing the bride's mind. The vow is
      ; spoken and HEARD; the reciprocal marriage below is her own rule on hearing it.
      ; Commented out pending that redesign.
      ; (formalize-marriage ?betrothed)
      )))

; Reciprocal marriage: learning {?p spouse @self} while betrothed to ?p marries @self
; back in their own mind - the bride hears the vow at the altar; an absent bride
; learns by gossip and marries then.
(think spouse-reciprocate
  (belief -{@self spouse ?}
    (role ?p {@self fiancee ?p}
             {?p spouse @self}:?vow
      (effects
        (end-belief {@self fiancee ?p})
        (begin-belief {@self spouse ?p /caused_by ?vow})))))
