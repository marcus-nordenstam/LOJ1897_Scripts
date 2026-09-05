; ----------------------------------------------------------------------------
; enter - the generic "get inside a venue" chain (§5.11). Any lane that wants the actor
; INSIDE a structure raises {@self enter ?venue} as a bodyless TASK; these two GENERIC
; tries decompose the running enter task STRAIGHT into the ONE movement PRIMITIVE (WALK).
; The actions promote directly off the maintain-proposals, so there is no intermediate go
; goal and no separate stepping rung. Each
; leg is auto-/caused_by the running enter task (the head gate pins it).
;
;   OUTSIDE the venue and not yet at its door -> walk to the stand-off point at its face
;     ((front-park-point ?s), funcs/spatial.mc - a POINT, so WALK needs no threshold variant).
;   AT the threshold, the entrance {?s room ?entry} known (taught by perception at the
;     door) and the venue open -> step into the entrance room.
;
; and (not stable-or): the two guards are COMPLEMENTARY (OUTSIDE xor AT-THRESHOLD), so
; exactly one try is ever live - the exclusivity a lock would impose is already inherent
; in the gates, and an inclusive (and ...) reproduces the original two independent rungs
; exactly (a stable-or lock would only add a one-cycle handoff latency here). The OUTSIDE
; try holds while walking; reaching the threshold drops its (when) and raises the
; AT-THRESHOLD try's - the threshold->interior handoff is emergent. Reaching the interior
; drops the minting lane's gate, ceasing the enter proposal; the shared pipeline tears the
; task down.
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
  (tar @excl structure)
  (and
    (try
      (when (and (not (spatial @self building ?s))
                 (not (at-threshold ?s))))
      (effects
               (maintain-proposal {@self WALK (front-park-point ?s)})))
    (try
      (when (and (at-threshold ?s)
                 -{?s struct-status [k closed]}))
      (effects  (head (spatial ?s parts [k interior-space room] /env)): ?first_room
                (observe ?first_room): ?obs_room
                (maintain-proposal {@self WALK ?obs_room})))
    ; INSIDE ?s: the barrier is crossed, so the task has done its one job and says so.
    (try
      (when (spatial @self building ?s))
      (effects (set-outcome ?enter-rel /succ)))))
