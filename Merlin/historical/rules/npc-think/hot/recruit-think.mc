; ----------------------------------------------------------------------------
; recruit - the ORG side of the labour market. The recruit-staff TASK (post an advert,
; office round, resolve the batch) lives in npc-tasks/recruit-staff-task.hs; the advertise
; subtask in npc-tasks/advertise-task.hs; the work-spawn rung in npc-tasks/work-task.hs.
;
; What stays here is the take_down lane. It is not a task performer: the recruit-staff task
; has already CONCLUDED by the time the book is full, so the take-down cannot be a rung of
; it. It rides the records the acts left behind instead of a bookkeeping state - the ended
; advertise belief names the org, and @self's ended WRITE names the advert he penned.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think take_down_filled
  ; ?ad ENUMERATED: an officer can hold several posted adverts at once, and a single @self
  ; bind would take the first advert found and only ever test THAT one's org.
  (role ?ad [k job-description] {@self WRITE ?ad ? /succ})
  (when (and {@self advertise ?org /succ}
             {?org isa ?ok}
             {?org employee-register ?reg}
             (>= (table-count ?reg)
                 (if (table-match public_orgs kind ?ok employee-count ?ec) (then ?ec) (else 2)))))
  (utility duty)
  (effects (maintain-proposal {@self DESTROY-ENTITY ?ad})))
