; ----------------------------------------------------------------------------
; explore - learn a building's rooms. While @self does not yet know all of
; its home's rooms, `explore ?home` is MAINTAINED; the performing rung walks
; to the FIRST unobserved room, perception teaching it on arrival, until every
; room is observed and the drive ceases. This bootstraps the {building part room} /
; {mail_stack location room} knowledge read_mail (and any home-room behaviour) binds.
; (`explore` is the existing task in Tasks.mon - (motor legs) (tar @excl).)
;
; The room source is ENV-TRUTH: (attr-values ?bldg parts [k interior_space room])
; enumerates the building's ACTUAL rooms - most UNOBSERVED, which is the point - as
; role candidates (the sanctioned frontier carve-out, like closest-unobserved for
; structures). (not (observed ?room)) filters to the unseen; (select (policy
; first-match)) walks them one at a time, no thrash.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The role binding IS the "an unobserved room remains" test: it binds the first
; unseen room while any exists, and binds nothing once the house is fully known -
; so the maintain ceases and explore ends on its own.
(npc-think want_explore
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (role ?room (attr-values ?home parts [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (when (in-building ?home))
  (utility 70)
  (effects (maintain-proposal {@self explore ?home})))

(npc-think explore_go
  (task {@self explore ?bldg})
  (role ?home {@self home ?home})
  (role ?room (attr-values ?home parts [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (utility 71)
  (effects (maintain-proposal {@self go ?room})))
