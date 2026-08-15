; ----------------------------------------------------------------------------
; go - the smart TRAVEL TASK. THE one place that reasons about reaching a destination:
; a structure, a room, or an exterior space. Every lane that wants the actor somewhere
; issues {@self go <dest>} for ANY dest and never branches on its kind - this task
; dispatches to the primitives:
;   enter  - get inside a structure (front-park + step into a room), the enter chain.
;   walk   - the dumb relocate into a space (walk_action / go_action.hs).
;
; A ROOM is reached by entering its BUILDING first (if outside) then walking to the room;
; a STRUCTURE by entering it; an EXTERIOR space by walking. go proposes enter / walk as
; sub-acts, so it inherits their body motor, and the pipeline tears the promoted go task
; down when the minting lane ceases (arrival is the lane's OWN gate - worship_go shape -
; so go needs no outcome rung, exactly like the enter task).
;
; Reaching a KNOWN room needs {?dest building ?bldg} in belief (learned by visiting): a
; room whose building the actor does not yet know simply does not route here - the caller
; is responsible for producing that knowledge (explore), never go.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; STRUCTURE dest, not yet inside -> enter it (enter lands the actor in one of its rooms).
(npc-think go_enter_structure
  (task {@self go ?dest})
  (when (and (is-a ?dest [k structure])
             (not (in-building @self ?dest))))
  (effects (maintain-proposal {@self enter ?dest})))

; ROOM dest, not yet in its building -> enter the building first.
(npc-think go_enter_room_building
  (task {@self go ?dest})
  (when (and (is-a ?dest [k interior_space])
             (not (in-building @self (building ?dest)))))
  (effects (maintain-proposal {@self enter (building ?dest)})))

; ROOM dest, in its building but not standing in it -> walk to the room.
(npc-think go_walk_room
  (task {@self go ?dest})
  (when (and (is-a ?dest [k interior_space])
             (in-building @self (building ?dest))
             (not (at_location @self ?dest))))
  (effects (maintain-proposal {@self walk ?dest})))

; EXTERIOR-SPACE dest -> walk straight to it (no structure to enter).
(npc-think go_walk_exterior
  (task {@self go ?dest})
  (when (and (is-a ?dest [k exterior_space])
             (not (at_location @self ?dest))))
  (effects (maintain-proposal {@self walk ?dest})))
