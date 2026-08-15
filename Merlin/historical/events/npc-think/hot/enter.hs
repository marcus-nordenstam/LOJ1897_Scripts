; ----------------------------------------------------------------------------
; enter - the generic "get inside a venue" chain (§5.11). Any lane that wants the actor
; INSIDE a structure raises {@self enter ?venue} as a bodyless TASK ((maintain-proposal ...),
; promoted + run); these two GENERIC rungs decompose the running enter task STRAIGHT into the
; movement PRIMITIVES (go_to_threshold_act / go_act). The actions promote directly off these
; maintain-proposals, so there is no intermediate go / go_to_threshold goal and no separate
; stepping rung. Each leg is auto-/caused_by the running enter task (the (task ...) gate pins
; it), inheriting its drive - which inherits the desire that raised the enter proposal - so
; the go for the keenest desire wins the body.
;
;   go_to_threshold: OUTSIDE the venue and not yet at its door -> front-park at the face.
;   step_in: AT the threshold, the entrance {?s room ?entry} known (taught by perception at the
;     door) and the venue open -> step into the entrance room.
;
; The (task {@self enter ?s}) gate is PUSH-armed by the enter task belief's write and bars
; activation before any role work: an NPC with no running enter task never even attempts
; these rungs; the free ?s binds off the matched task belief. The spatial predicates
; (in-building @self / at-threshold) stay in (when); the mutually-exclusive OUTSIDE vs
; AT-THRESHOLD gates make the threshold->interior handoff emergent. Reaching the interior
; drops the minting lane's gate, ceasing the enter proposal; the shared pipeline then tears
; the promoted enter task down.
;
; Locked-door / key / break-and-enter rungs plug into this same chain later (§5.11 deferred).
; ----------------------------------------------------------------------------

(npc-think enter_go_to_threshold
  (task {@self enter ?s})
  (when (and (not (in-building @self ?s))
             (not (at-threshold @self ?s))))
  (effects (debug-print "TRACE-ENTERTASK dest=?s")
           (maintain-proposal {@self go_to_threshold ?s})))

(npc-think enter_step_in
  (task {@self enter ?s})
  (when (and (at-threshold @self ?s)
             (room ?s): ?entry
             (none {?s struct_status [k closed]})))
  (effects (debug-print "TRACE-STEPIN bld=?s room=?entry")
           (maintain-proposal {@self walk ?entry})))
