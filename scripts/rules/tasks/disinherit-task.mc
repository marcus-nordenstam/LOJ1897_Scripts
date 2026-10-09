; ----------------------------------------------------------------------------
; disinherit (task) - the benefactor cuts an heir out. A real DO the benefactor
; PERFORMS, never a fabricated omniscient record (Marcus 2026-08-19).
;
; Disinheriting is changing a will - a physical act, unobservable in itself. The
; victim (or a third party) learns of it only through a real channel: the benefactor
; TELLS them, or they realize it (an heir who is no longer an heir has been
; disinherited - the lover-realization shape, kicking in on reading the will).
;
; INTERIM (no will-documents yet): the task simply SAYs the disinheritance to the
; victim - {@self disinherit ?victim}. Performing the SAY both enacts it and plants
; the knowledge in the victim's mind (a co-present listener adopts {benefactor
; disinherit victim}). The proper will-writing act + heir-realization rung land when
; will-documents do.
;
; Proposed by bonded-incident-disinherit (a grudge-holding benefactor + a detested
; heir-child).
; ----------------------------------------------------------------------------


(task {@self disinherit ?victim}:?disinherit
  (tar [k human] @object)
  (construed-act abandonment-act wrong-act) (contradicts kin-loyalty)
  (and
    ; FIND the victim: his home, when where he is is unknown.
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (not (spatial ?victim co-located @self))
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go-to ?vhome}))))

    ; TELL him the disinheritance. He ADOPTS {benefactor disinherit victim} from the
    ; utterance - real told-knowledge, no fiat cross-mind write.
    (try
      (when (or (spatial ?victim co-located @self) (spatial ?victim space)))
      (declare-utility errand always-pick)
      (effects
        (maintain-proposal {@self tell (utterable-msg [] {@self disinherit ?victim}) ?victim})))

    ; OUTCOME: the disinheritance was announced.
    (try
      (when {@self tell ? ?victim /succ /caused_by ?disinherit})
      (effects (set-outcome ?disinherit /succ)))

    ; ABANDON: the victim died before it could be announced.
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?disinherit /fail)))))
