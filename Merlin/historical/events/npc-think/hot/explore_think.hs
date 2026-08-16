; ----------------------------------------------------------------------------
; explore ?bldg - learn a building's rooms. The performing rung walks to the FIRST
; unobserved room of ?bldg, perception teaching it on arrival, until every room is
; observed and the drive ceases. This bootstraps the {building part room} /
; {mail_stack location room} knowledge wander / read_mail (and any home-room
; behaviour) binds. General over ?bldg: wander proposes it for the workplace as well
; as home; want_explore below is the standing HOME bootstrap driver.
;
; The room source is ENV-TRUTH: (env-parts ?bldg [k interior_space room])
; enumerates the building's ACTUAL rooms - most UNOBSERVED, which is the point - as
; role candidates (the sanctioned frontier carve-out). (not (observed ?room)) filters
; to the unseen; (select (policy first-match)) walks them one at a time, no thrash.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think want_explore
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (role ?room (env-parts ?home [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (when (in-building @self ?home))
  (utility idle 700)
  (effects (maintain-proposal {@self explore ?home})))

(npc-think explore_walk
  (task {@self explore ?bldg})
  (role ?room (env-parts ?bldg [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (utility 710)
  (effects (maintain-proposal {@self WALK ?room})))
