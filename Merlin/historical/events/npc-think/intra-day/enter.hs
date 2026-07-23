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
; The mutually-exclusive spatial gates (OUTSIDE vs AT-THRESHOLD) make the threshold->interior
; handoff EMERGENT. The spatial predicates are movement-reactive (§5.10): the actor's own
; arrival re-selects the next rung at its post-completion decision point. Reaching the interior
; drops the minting lane's gate (in-building), which ceases the enter proposal; the shared
; pipeline then tears the promoted enter task down.
;
; The running enter task is matched with (believes {@self enter ?s}), which binds ?s off the task
; belief on the first eval and existence-tests it on the maintenance re-check (a `bind` would trip
; the fully-bound-field guard once ?s is restored from the fire-time stash).
;
; Locked-door / key / break-and-enter rungs plug into this same chain later (§5.11 deferred) -
; they touch zero minting lanes.
; ----------------------------------------------------------------------------

(npc-think enter_go_to_threshold
  (schedule always)
  (when (and (believes {@self enter ?s})
             (not (in-building ?s))
             (not (at-threshold @self ?s))))
  (effects (maintain-proposal {@self go_to_threshold ?s} /cause {@self enter ?s})))

(npc-think enter_step_in
  (schedule always)
  (when (and (believes {@self enter ?s})
             (at-threshold @self ?s)
             (believes {?s room ?entry})
             (open ?s)))
  (effects (maintain-proposal {@self go ?entry} /cause {@self enter ?s})))
