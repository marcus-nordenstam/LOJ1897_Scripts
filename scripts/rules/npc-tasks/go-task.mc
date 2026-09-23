; ----------------------------------------------------------------------------
; go - THE movement task. It is handed a CELL and gets the man onto it from wherever he
; stands, and it is the only rule in the corpus that reconciles the building he is in
; against the building he is going into.
;
; A DESTINATION IS A CELL. Not a room, not a building, not a bounds handle - a spot on the
; env grid one man can stand on and hold. Everything else was under-specified: "walk to
; the room" meant the middle of the room's box, which is half a storey up on a person and
; half a church up on a church, and it sent every man who wanted that room to one point.
; A cell has a floor, an owner and a size, so arrival is an OVERLAP rather than a distance
; under some threshold.
;
; Which building a cell leads into is read off its ANCHOR - the entity it was claimed
; beside. A world-cell is anchored on nothing, which means where he already stands, so it
; never asks him to leave a building to reach it.
;
; The three rungs are complementary on containment and each handoff is emergent: while he
; is in the wrong building the first holds; the moment exit puts him out of doors his
; building is nothing and the second lights; once enter has him across the threshold the
; third carries him the rest of the way. Crossing the threshold is not a rung of its own -
; a structure's rooms are ONE navmesh island and its doors are passages, so a doorway and
; a corridor are both just a path.
;
; go NEVER proposes enter, and that is what keeps the layering acyclic: enter resolves a
; place into a cell and hands it here, so a rung here that answered with enter would hand
; it straight back, and since neither act takes any time the pair spins the clock in place.
; A barrier is the lane's business at the point it asks to get IN, not a rescue mid-journey.
; Finding a place he cannot point to is not go's work either: go is given a cell, and a cell can
; only be claimed beside something already found. That reasoning lives in enter.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-task {@self go ?dest}:?go-rel
  (tar @excl)
  ; ARRIVAL IS OVERLAP - his box on the cell. The task runs while it is not, and the cease
  ; says what stopping meant, so a withdrawal mid-journey and an arrival read the one test
  ; and the /succ overwrites the /interrupted a withdrawal stamps.
  (when (not (overlaps ?dest @self)))
  (cease (if (overlaps ?dest @self) (then (set-outcome ?go-rel /succ))))
  (and
    ; WRONG BUILDING - the cell is anchored on something outside the building he stands in,
    ; a destination out of doors included (a target in no building answers @false to the
    ; membership test, which is the reading we want). Leave it first.
    (try
      (when (poll (cell-anchor ?dest): ?anchor
                  (spatial @self building): ?here
                  (not (spatial @self building (spatial ?anchor building)))))
      (effects
        (check (is-cell ?dest))
        (maintain-proposal {@self exit ?here})))
    ; SAME BUILDING, or both out of doors, or a world-cell (which means here): one leg.
    (try
      (when (poll (or (unsubstantial (cell-anchor ?dest))
                      (spatial @self building (spatial (cell-anchor ?dest) building))
                      (and (unsubstantial (spatial @self building))
                           (unsubstantial (spatial (cell-anchor ?dest) building))))))
      (effects
        (check (is-cell ?dest))
        (maintain-proposal {@self WALK ?dest})))))
