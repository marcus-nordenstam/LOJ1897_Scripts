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

(include "../../definitions/roles.hs")

(npc-task {@self disinherit ?victim}:?disinherit
  (tar human)
  (construed_act abandonment_act wrong_act)
  (and
    ; REACH the victim - route to them, or their home if their location is unknown.
    (try
      (when (and (not (co-present ?victim @self))
                 (location ?victim): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (not (co-present ?victim @self))
                 (unknown (location ?victim))))
      (effects (maintain-proposal {@self go (home-of ?victim)})))

    ; CO-PRESENT: SAY the disinheritance. The co-present victim ADOPTS {benefactor
    ; disinherit victim} from the utterance - real told-knowledge, no fiat cross-mind
    ; write.
    (try
      (when (co-present ?victim @self))
      (utility errand always-pick)
      (effects
        (maintain-proposal {@self SAY (utterable-msg (to ?victim) {@self disinherit ?victim}) ?victim})))

    ; OUTCOME: the disinheritance was announced (the SAY landed).
    (try
      (when (any {@self SAY ? ?victim /succ /caused_by ?disinherit}))
      (effects (set-outcome ?disinherit succ)))

    ; ABANDON: the victim died before it could be announced.
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?disinherit fail)))))
