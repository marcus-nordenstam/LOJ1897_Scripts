; ----------------------------------------------------------------------------
; approach - get @self standing BESIDE a thing, whatever it is: a building he is bound
; for, a stack he means to read from, a man he wants a word with. Where enter puts him
; inside a place, approach puts him next to an entity, and the cell it claims is anchored
; ON that entity - so the spot travels with the thing and says what it is a spot beside.
;
; The same two-phase rule: outside near_building_m he heads for a spot and reserves
; nothing, inside it he claims one and finishes on what he got. The phases are split on
; DISTANCE and not on sight, deliberately - a claim released the moment a cart passes in
; front of him is a claim he re-takes somewhere else a moment later, and the man weaves.
; Whether he knows where the thing IS at all is a different question, and its answer is
; the perceived box (env-cell) or the finding lanes in enter.
;
; Both legs go through go, because the thing may be indoors or out and he may be either:
; reconciling that is exactly what go is for.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-task {@self approach ?ent}:?approach-rel
  (tar @excl @object)
  ; Beside it is close enough to act on it, and that is what the caller wanted.
  (when (poll (not (< (distance @self ?ent) (near_reach_m)))))
  (cease (if (< (distance @self ?ent) (near_reach_m)) (then (set-outcome ?approach-rel /succ))))
  (and
    ; FAR: a spot before its face, held by nobody. It is read from the box he REMEMBERS,
    ; so a thing he has seen once can be walked to while it is out of sight, and a thing
    ; he has never seen answers nothing and this rung does not fire.
    (try
      (when (poll (not (< (distance @self ?ent) (near_building_m)))))
      (effects
        (travel-cell ?ent): ?spot
        (if (is-cell ?spot) (then (maintain-proposal {@self go ?spot})))))
    ; NEAR: now reserve one, and take the last paces onto whatever was free.
    (try
      (when (poll (< (distance @self ?ent) (near_building_m))))
      (when (poll (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?ent]
                                           [/at_or_near @self]): ?cell))
      (effects (maintain-proposal {@self go ?cell})))))
