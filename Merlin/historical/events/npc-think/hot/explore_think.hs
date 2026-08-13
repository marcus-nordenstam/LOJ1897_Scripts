; ----------------------------------------------------------------------------
; explore ?bldg - learn a building's rooms. The performing rung walks to the FIRST
; unobserved room of ?bldg, perception teaching it on arrival, until every room is
; observed and the drive ceases. This bootstraps the {building part room} /
; {mail_stack location room} knowledge wander / read_mail (and any home-room
; behaviour) binds. General over ?bldg: wander proposes it for the workplace as well
; as home; want_explore below is the standing HOME bootstrap driver.
;
; The room source is ENV-TRUTH: (attr-values ?bldg parts [k interior_space room])
; enumerates the building's ACTUAL rooms - most UNOBSERVED, which is the point - as
; role candidates (the sanctioned frontier carve-out). (not (observed ?room)) filters
; to the unseen; (select (policy first-match)) walks them one at a time, no thrash.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think want_explore
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (role ?room (attr-values ?home parts [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (when (in-building @self ?home))
  (utility 70)
  (effects (maintain-proposal {@self explore ?home})))

; PERFORM: while INSIDE ?bldg, look into its next unseen room. The room OBBs of many
; buildings overlap (no distinct interior layout), so a physical (go ?room) cannot move
; the actor between them - but standing in the building you CAN see into the next room.
; (observe ?room) perceives it (its {room building} containment + contents), one room per
; firing, so the drive walks the layout and ceases once every room is seen - bounded, no
; frenzy, and interruption just pauses it (each observation is persistent progress).
(npc-think explore_go
  (task {@self explore ?bldg})
  (role ?room (attr-values ?bldg parts [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (when (in-building @self ?bldg))
  (utility 71)
  (effects (observe ?room)))
