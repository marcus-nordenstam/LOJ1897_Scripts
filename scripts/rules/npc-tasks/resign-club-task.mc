; ----------------------------------------------------------------------------
; resign-club - the DOING of resigning from my own club: call at a clubhouse, strike
; my row off my club's roll, and give up my membership belief. Focusless - a man
; resigns from his OWN club, resolved off {@self member-of ?org}. The decision
; (clubs_think club_resignation) proposes this task and owns its life (maintains until
; my member-of is gone). The roll resolution is the task's job; the dumb LEAVE-ROLL
; just crosses out the row.
; ----------------------------------------------------------------------------

(npc-task {@self resign-club}:?rc-rel
  (and
    ; GO: not at a clubhouse -> travel to one (nearest known).
    (try
      (role ?go_dest [k building social-clubhouse]
            (select (score (near @self ?go_dest)) (policy roulette unknown-last))
        (when (not (is-a (spatial @self building) [k building social-clubhouse])))
        (effects (maintain-proposal {@self go ?go_dest}))))

    ; LEAVE-ROLL: at a clubhouse -> resolve my own club's roll and strike my row.
    (try
      (when (is-a (spatial @self building) [k building social-clubhouse]))
      (effects
        (any {@self member-of ?org})
        (any {?org membership-roll ?roll})
        ; No roll belief -> no row to strike. It was a (check ?roll) ASSERT, but a
        ; member-of org whose papers @self has never read is a legitimate state.
        (if ?roll (then (maintain-proposal {@self LEAVE-ROLL ?roll})))))

    ; REALIZE: my row is gone -> end my membership belief (trips the decision's completion).
    (try
      (effects
        (any {@self member-of ?org})
        (any {?org membership-roll ?roll})
        (if (not (table-match (attr ?roll writing) member (name @self)))
            (then (end-belief {@self member-of ?org})
                  (set-outcome ?rc-rel /succ)))))))
