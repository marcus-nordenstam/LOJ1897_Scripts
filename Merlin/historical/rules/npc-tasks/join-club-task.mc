; ----------------------------------------------------------------------------
; join-club ?art - the DOING of joining a club: go to the clubhouse, ENROL on its
; roster, and come to know myself a member. The decision (clubs_think club_joining)
; proposes this task and owns its life (it maintains the proposal until I hold
; member-of, then withdraws). ?art is the club's articles; its clubhouse is
; articles-building ?art. The register resolution is the task's job; the dumb ENROL
; just files the row. Others learn me by reading the roster (read_roster).
; ----------------------------------------------------------------------------

(npc-task {@self join-club ?art}:?jc-rel
  (tar document)
  (and
    ; GO: not at the clubhouse -> travel to it.
    (try
      (role ?art_org {?art_org record ?art}
                      {?art_org workplace ?venue}
                      (not (spatial @self building ?venue)))
      (effects (maintain-proposal {@self enter ?venue})))

    ; ENROL: at the clubhouse -> resolve the club's roster and file my membership row.
    (try
      (role ?art_org {?art_org record ?art}
                      {?art_org workplace ?venue}
                      (spatial @self building ?venue))
      (effects
        (o {?art declares-org @o}): ?org
        (any {?org employee-register ?reg})
        ; No register belief -> nothing to enrol on. It was a (check ?reg) ASSERT, but an
        ; org with no register is a legitimate state: (o ..) INVENTS one when it recalls
        ; nothing, and an invented org has no papers.
        (if ?reg (then (maintain-proposal {@self ENROL ?reg [k membership]})))))

    ; REALIZE: my row is on the roster -> I now know I am a member (self-knowledge).
    ; Minting member-of trips the decision's completion gate, which withdraws the task.
    (try
      (effects
        (o {?art declares-org @o}): ?org
        (any {?org employee-register ?reg})
        (if (table-match (attr ?reg writing) worker @self)
            (then (begin-belief {@self member-of ?org})))))))
