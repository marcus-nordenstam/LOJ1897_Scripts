; ----------------------------------------------------------------------------
; resign-club - the DOING of resigning from my own club: call at a clubhouse, strike
; my row off my club's roster, and give up my membership belief. Focusless - a man
; resigns from his OWN club, resolved off {@self member-of ?org}. The decision
; (clubs_think club_resignation) proposes this task and owns its life (maintains until
; my member-of is gone). The register resolution is the task's job; the dumb UNENROL
; just crosses out the row.
; ----------------------------------------------------------------------------

(npc-task {@self resign-club}:?rc-rel
  (and
    ; GO: not at a clubhouse -> travel to one (nearest known).
    (try
      (role ?go_dest [k building social-clubhouse]
            (select (score (near @self ?go_dest)) (policy roulette)))
      (when (not (is-a (spatial @self building) [k building social-clubhouse])))
      (effects (maintain-proposal {@self enter ?go_dest})))

    ; UNENROL: at a clubhouse -> resolve my own club's roster and strike my row.
    (try
      (when (is-a (spatial @self building) [k building social-clubhouse]))
      (effects
        (any {@self member-of ?org})
        (any {?org employee-register ?reg})
        (check ?reg)
        (maintain-proposal {@self UNENROL ?reg})))

    ; REALIZE: my row is gone -> end my membership belief (trips the decision's completion).
    (try
      (effects
        (any {@self member-of ?org})
        (any {?org employee-register ?reg})
        (if (not (table-match (attr ?reg writing) worker @self))
            (then (end-belief {@self member-of ?org})))))))
