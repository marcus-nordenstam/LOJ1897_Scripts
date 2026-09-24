; ----------------------------------------------------------------------------
; plan-gathering ?kind ?months - the host STAGES an occasion ?months ahead and has an
; invitation carried to every friend whose home he can place.
;
; Staging is MENTAL: an occasion is a Mental Object (concepts.mon `occasion`), never an
; env entity - it has no body, no archetype and no place in the world. What it has is a
; host, a venue, hours and a date, and those beliefs ARE the gathering. The invitations
; are the opposite: paper, physical, so each one is a sub-task that mints it through the
; CREATE-ENTITY action rather than from here.
;
; The occasion is stashed on the running task under `occasion`, so a restarted round
; re-reads it instead of inventing a second gathering for the same evening.
;
; Staging is all this task does, and it concludes the moment it is done. INVITING is
; not part of it: it is a standing condition (I organize an occasion, this friend has
; no invitation yet) that raises one invite-guest per guest, so it lives in a driver -
; a sibling rung here would die with the task the instant the staging concluded.
; ----------------------------------------------------------------------------


(npc-task {@self plan-gathering ?kind ?months}:?pg-rel
  (sequence
    (role ?my-home {@self home ?my-home}

      ; The occasion itself - invented once, then read back from the blackboard.
      (stage
        (effects
          (if (bb-any ?pg-rel occasion)
              (then (bind (bb-read ?pg-rel occasion) ?occ))
              (else
                (o /invent ?kind): ?occ
                (bb-write ?pg-rel occasion ?occ)))))

      ; Its constitutive facts. A lead that runs past December rolls into next year - and
      ; (month) counts from ZERO, so december is 11 and the twelfth month past it is 23.
      ; Each is gated on what is already there, so a restarted stage adds nothing twice.
      (stage
        (effects
          (+ (month) ?months): ?pg-m
          (if (> ?pg-m 11)
              (then (create-date (+ (year) 1) (- ?pg-m 12) 15))
              (else (create-date (year) ?pg-m 15))): ?pg-date
          (if (none {?occ host ?})         (then (begin-belief {?occ host @self})))
          (if (none {?occ venue ?})        (then (begin-belief {?occ venue ?my-home})))
          (if (none {?occ hours ?})        (then (begin-belief {?occ hours 19 23})))
          (if (none {?occ held-on ?})      (then (begin-belief {?occ held-on ?pg-date})))
          (if (none {@self organize ?occ}) (then (begin-belief {@self organize ?occ})))))

      (stage
        (effects
          (bb-clear ?pg-rel occasion)
          (set-outcome ?pg-rel /succ))))))
