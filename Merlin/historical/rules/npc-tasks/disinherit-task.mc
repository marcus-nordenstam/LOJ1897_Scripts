; ----------------------------------------------------------------------------
; disinherit (npc-task) - the benefactor cuts an heir out. A real DO the benefactor
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
; Proposed by bonded_incident_disinherit (a grudge-holding benefactor + a detested
; heir-child).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self disinherit ?victim}:?disinherit-rel
  (tar human)
  (construed-act abandonment-act wrong-act) (contradicts kin-loyalty)
  (and
    ; REACH the victim - route to them, or their home if their location is unknown.
    (try
      (when (and (not (spatial ?victim co-located @self))
                 (spatial ?victim space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (spatial ?victim co-located @self))
                 (unknown (spatial ?victim space))
                 {?victim home ?vhome}))
      (effects (maintain-proposal {@self go ?vhome})))

    ; CO-PRESENT: SAY the disinheritance. The co-present victim ADOPTS {benefactor
    ; disinherit victim} from the utterance - real told-knowledge, no fiat cross-mind
    ; write.
    (try
      (when (spatial ?victim co-located @self))
      (utility errand always-pick)
      (effects
        (maintain-proposal {@self SAY (utterable-msg {@self disinherit ?victim}) ?victim})))

    ; OUTCOME: the disinheritance was announced (the SAY landed).
    (try
      (when {@self SAY ? ?victim /succ /caused_by ?disinherit-rel})
      (effects (set-outcome ?disinherit-rel /succ)))

    ; ABANDON: the victim died before it could be announced.
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?disinherit-rel /fail)))))
