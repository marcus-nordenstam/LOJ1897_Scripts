; ----------------------------------------------------------------------------
; vow-realized / spouse-reciprocate reconcile the marriage beliefs the vow makes -
; they gate on fiancee / spouse, not on any attend token, so they stay here.
; ----------------------------------------------------------------------------

; An occasion's month gone by unattended: the obligation lapses and strains @self over the missed
; occasion, the strain caused by its date, which he still remembers.
(think attendance-lapsed
  (role ?occ {?occ held-on ?held-on}:?date
             {@self obligation {@self attend ?occ} ?}
    (when (date-before-current-month ?held-on))
    (effects
      (any {@self obligation {@self attend ?occ} ?}): ?obligation
      (mint-pressure-caused [k obligation-strain] ?occ 336.0 ?date)
      (end-belief ?obligation))))

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
  (role @self -{@self spouse ?}
    (role ?p {@self fiancee ?p}
             {?p spouse @self}
      (effects
        (end-belief {@self fiancee ?p})
        (begin-belief {@self spouse ?p})))))
