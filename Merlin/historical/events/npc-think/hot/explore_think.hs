; ----------------------------------------------------------------------------
; explore ?bldg - learn a building's rooms. The performing rung walks to the FIRST
; unobserved room of ?bldg, perception teaching it on arrival, until every room is
; observed and the drive ceases. This bootstraps the {building part room} /
; {mail_stack location room} knowledge wander / read_mail (and any home-room
; behaviour) binds.
;
; DEMAND-DRIVEN, never speculative: exploration is a MEANS, proposed only by a task
; that needs to know where something is (read_mail -> locate -> wander -> explore),
; so it inherits that task's band and never starves as a standing idle bootstrap
; would. There is no want_explore driver - a mind explores its home exactly when a
; running task requires a room it has not yet seen.
;
; The room source is ENV-TRUTH: (env-parts ?bldg [k interior_space room])
; enumerates the building's ACTUAL rooms - most UNOBSERVED, which is the point - as
; role candidates (the sanctioned frontier carve-out). (not (observed ?room)) filters
; to the unseen; (select (policy first-match)) walks them one at a time, no thrash.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think explore_walk
  (task {@self explore ?bldg})
  (role ?room (env-parts ?bldg [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (effects (maintain-proposal {@self WALK ?room})))
