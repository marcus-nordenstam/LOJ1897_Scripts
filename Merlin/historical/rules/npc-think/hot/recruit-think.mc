; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market. The recruit-staff TASK (post an advert,
; office round, resolve the batch) lives in npc-tasks/recruit-staff-task.hs; the advertise
; subtask in npc-tasks/advertise-task.hs; the work-spawn rung in npc-tasks/work-task.hs.
;
; What stays here is the take_down lane: it is POST-BELIEF driven (gated on {@self post ?ad
; ?org}, not the recruit-staff task), so it is not a task performer - the filled posting
; comes off the board whenever @self holds a post belief for an org whose book is full.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think take_down_filled
  ; ?ad ENUMERATED: an officer can hold several posted adverts at once, and a single @self
  ; bind would take the first post found and only ever test THAT ad's org.
  (role ?ad {@self post ?ad ?org})
  (when (and {?org isa ?ok}
             {?org employee-register ?reg}
             (>= (table-count ?reg)
                 (if (table-match public_orgs kind ?ok employee-count ?ec) (then ?ec) (else 2)))))
  (utility duty)
  (effects (maintain-proposal {@self DESTROY-ENTITY ?ad})))

(npc-think take_down_done
  (role ?ad {@self post ?ad ?org})
  (when {@self DESTROY-ENTITY ?ad /succ})
  (effects (end-belief {@self post ?ad ?org})))
