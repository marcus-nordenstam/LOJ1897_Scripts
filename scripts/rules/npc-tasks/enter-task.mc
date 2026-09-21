; ----------------------------------------------------------------------------
; enter - the generic "get inside a venue" chain (§5.11). Any lane that wants the actor
; INSIDE a structure raises {@self enter ?venue} as a bodyless TASK; these two GENERIC
; tries decompose the running enter task STRAIGHT into the ONE movement PRIMITIVE (WALK).
; The actions promote directly off the maintain-proposals, so there is no intermediate go
; goal and no separate stepping rung. Each
; leg is auto-/caused_by the running enter task (the head gate pins it).
;
;   The venue's box not yet SEEN -> the COARSE leg: walk to its bounds handle (the engine
;     lands a traveller before a structure's front face), and look at it on arrival.
;   Seen -> the NEAR-FIELD leg: claim a stand cell in front of it (held by the rung that
;     asked, released when it ceases) and walk onto it - distinct cells for two callers.
;   Standing on the cell, the venue open -> step into the entrance room.
;
; and (not stable-or): the guards are COMPLEMENTARY (box unseen / seen and off the cell /
; seen and on it), so exactly one try is ever live - the exclusivity a lock would impose is
; already inherent in the gates. Each handoff is emergent: the coarse walk's postlude makes
; the box seen, the short walk makes the cell overlap. Reaching the interior drops the
; minting lane's gate, ceasing the enter proposal; the shared pipeline tears the task down.
;
; enter is a TASK because crossing the shell of a structure is work in its own right: the
; door may be shut, locked or otherwise barred (which will spawn unlocking / forcing /
; find-another-way sub-tasks), and the entrance may itself have to be located. Moving
; about OUTSIDE is one lane and moving between rooms INSIDE is another; enter is the
; traversal of the mobile barrier between them. So it can genuinely FAIL - calling on a
; friend who is not home leaves you outside a locked door unless you force it - and it
; SUCCEEDS when it has put @self inside ?s.
;
; BOTH teardown paths are live and neither replaces the other: the minting lane's gate
; dropping ceases the proposal from outside (an interrupted approach), and the success
; rung below concludes it from inside once the job is done. A task that could ONLY be
; torn down from outside keeps its actor BUSY until that happens, and
; maybe_interrupt_wake re-deliberates a busy actor only for a STRICTLY higher bid - so
; a held enter silently ate every same-band duty queued behind it (the recruiting
; officer entered her office and then never ran the office round she came to do).
;
; The unified form still DECLARES the unhandled locked-door case: a CLOSED venue at the
; threshold matches NEITHER try, so the task stalls (locked-door / key / break-and-enter
; rungs plug into this same chain later - §5.11 deferred).
; ----------------------------------------------------------------------------

(npc-task {@self enter ?s}:?enter-rel
  (tar @excl [k structure] @object)
  ; The coarse leg reads the venue's box from ground truth: a bounds read is a perception
  ; signal, and a venue he is still walking toward is one he cannot yet see.
  (lint-waive env-read-outside-action)
  ; THE CONDITION THE TASK RUNS UNDER, its own and not any proposer's: he is not
  ; inside yet. It joins both legs' gates, and the moment the barrier is crossed it
  ; stops holding - so enter stops firing on its own terms rather than waiting to be
  ; torn down from outside.
  (when (not (spatial @self building ?s)))
  ; ...and the one test serves both endings. Crossed: /succ. Called off mid-approach:
  ; the withdrawal runs this too, at the last moment the record is still open, and it
  ; says nothing - leaving the /interrupted the withdrawal stamps, which is the truth.
  (cease (if (spatial @self building ?s) (then (set-outcome ?enter-rel /succ))))
  (and
    ; COARSE leg: to the venue's bounds handle - the engine lands him before its front
    ; face - while its box is still something he only knows of; the walk's postlude looks
    ; at it, which is what the near-field leg needs.
    (try
      (role @self (not (spatial @self building ?s))
        (when (unsubstantial (spatial ?s bounds)))
        (effects
                 (maintain-proposal {@self WALK (spatial ?s bounds /env)}
                                    [/postlude (observe ?s)]))))
    ; NEAR-FIELD leg: a stand cell of his own before the face, claimed once the venue is
    ; seen and held by this rung, then the short walk onto it.
    ; The cell is bound INSIDE the poll and tested there too: a bind made inside a poll is
    ; invisible to the conjunct ordering, so a separate (when ..) reading ?stand would run
    ; first, unbound, and the poll would never be reached. [/at_or_near @self] keeps the
    ; cell under his feet admissible: the default search is the cells AROUND him, so once
    ; he stood on his cell the next poll would hand him a neighbour, for ever.
    (try
      (when (poll (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?s]
                                           [/at_or_near @self]): ?stand
                  (not (overlaps ?stand @self))))
      (effects (maintain-proposal {@self WALK ?stand})))
    (try
      (when (poll (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?s]
                                           [/at_or_near @self]): ?stand
                  (overlaps ?stand @self)))
      (when -{?s struct-status [k closed]})
      (effects  (head (spatial ?s parts [k interior-space room] /env)): ?first_room
                (observe ?first_room): ?obs_room
                (maintain-proposal {@self WALK ?obs_room})))))
