; ----------------------------------------------------------------------------
; club_join_errand (npc-action lane) - the ACT half of the club-joining split.
;
; The decision (clubs.hs `club_joining`) minted {@self goal {@self JOIN_CLUB
; <club_articles>}}. The member goes to the clubhouse (npc-think lane) and is
; enrolled on the roster there - the co-presence the clubhouse's afforded rules
; read, instead of a faceless roster edit.
; ----------------------------------------------------------------------------

(npc-action {@self JOIN_CLUB ?club}
  (duration 60)
  (effects
    ; Enrol on the clubhouse roster (a membership row [member membership] - no rank)
    ; and mint the member_of belief in his own mind. The club org object is recalled
    ; from the articles he already knows (the join decision bound it to decide to come).
    (read-doc-record [k articles_of_incorporation] ?club (kind ?ck) (register ?reg))
    (check ?reg)
    (write-doc-record [k employee_register] ?reg (worker @self) (job [k membership]))
    (imagine-or-recall ?ck {?club declares_org ?org})
    (begin-belief {@self member_of ?org})
    (set-outcome {@self JOIN_CLUB} succ)))
