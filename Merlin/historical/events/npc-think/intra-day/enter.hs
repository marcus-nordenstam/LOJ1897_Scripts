; ----------------------------------------------------------------------------
; enter - the generic "get inside a venue" chain (§5.11). Any lane that wants the actor
; INSIDE a structure raises {@self enter ?venue} as a bodyless TASK ((maintain-proposal ...),
; promoted + run); these two GENERIC rungs decompose the running enter task STRAIGHT into the
; movement PRIMITIVES (go_to_threshold_act / go_act). The actions promote directly off these
; maintain-proposals, so there is no intermediate go / go_to_threshold goal and no _step
; re-proposer. Each leg /causes the enter task, inheriting its drive - which inherits the desire
; that raised the enter proposal - so the go for the keenest desire wins the body.
;
;   go_to_threshold: OUTSIDE the venue and not yet at its door -> front-park at the face.
;   step_in: AT the threshold, the entrance {?s room ?entry} known (taught by perception at the
;     door) and the venue open -> step into the entrance room.
;
; The running enter task is matched with a CACHED self-gate (role @self (believes {@self enter
; ?s})): an NPC with no enter task fails the gate at zero cost (empty object-cache set), so only
; those actually routing pay; the free ?s binds off the task belief at fire (t_role fire-bind).
; The spatial predicates (in-building / at-threshold) stay in (when) - they are movement-reactive
; (§5.10), so on-commit re-selects the next rung at the actor's post-completion decision point;
; the mutually-exclusive OUTSIDE vs AT-THRESHOLD gates make the threshold->interior handoff
; emergent. Reaching the interior drops the minting lane's gate, ceasing the enter proposal; the
; shared pipeline then tears the promoted enter task down.
;
; Locked-door / key / break-and-enter rungs plug into this same chain later (§5.11 deferred).
; ----------------------------------------------------------------------------

(npc-think enter_go_to_threshold
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self enter ?s}))
  (when (and (not (in-building ?s))
             (not (at-threshold @self ?s))))
  (effects (maintain-proposal {@self go_to_threshold ?s} /cause {@self enter ?s})))

(npc-think enter_step_in
  (schedule on-commit)
  (if-blocked hold)
  (role @self (believes {@self enter ?s}))
  (when (and (at-threshold @self ?s)
             (believes {?s room ?entry})
             (open ?s)))
  (effects (maintain-proposal {@self go ?entry} /cause {@self enter ?s})))
