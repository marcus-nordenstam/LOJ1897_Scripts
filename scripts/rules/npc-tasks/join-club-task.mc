; ----------------------------------------------------------------------------
; join-club ?art - the DOING of joining a club: go to the clubhouse, JOIN-ROLL onto its
; roll, and come to know myself a member. The decision (clubs_think club_joining)
; proposes this task and owns its life (it maintains the proposal until I hold
; member-of, then withdraws). ?art is the club's articles; its clubhouse is
; articles-building ?art. The roll resolution is the task's job; the dumb JOIN-ROLL
; just files the row. Others learn me by reading the roll (read_roster).
; ----------------------------------------------------------------------------

(npc-task {@self join-club ?art}:?jc-rel
  (tar document)
  (and
    ; GO: not at the clubhouse -> travel to it.
    (try
      (role ?art_org {?art_org record ?art}
                      {?art_org workplace ?venue}
                      (not (spatial @self building ?venue))
        (effects (maintain-proposal {@self enter ?venue}))))

    ; JOIN-ROLL: at the clubhouse -> resolve the club's roll and file my membership row.
    (try
      (role ?art_org {?art_org record ?art}
                      {?art_org workplace ?venue}
                      (spatial @self building ?venue)
        (effects
          (o {?art declares-org @o}): ?org
          (any {?org membership-roll ?roll})
          ; No roll belief -> nothing to join. It was a (check ?roll) ASSERT, but an
          ; org with no roll is a legitimate state: (o ..) INVENTS one when it recalls
          ; nothing, and an invented org has no papers.
          (if ?roll (then (maintain-proposal {@self JOIN-ROLL ?roll}))))))

    ; REALIZE: my row is on the roll -> I now know I am a member (self-knowledge).
    ; Minting member-of trips the decision's completion gate, which withdraws the task.
    (try
      (effects
        (o {?art declares-org @o}): ?org
        (any {?org membership-roll ?roll})
        (if (table-match (attr ?roll writing) member (name @self))
            (then (begin-belief {@self member-of ?org})
                  (set-outcome ?jc-rel /succ)))))))
