; ----------------------------------------------------------------------------
; enter - THE access task: get @self inside a place, finding it first if he cannot yet
; point to one. Where go is handed a cell and moves, enter is handed a PLACE - a structure
; or a space - and works out which cell inside it he should be standing on.
;
; That split is the whole design. A destination a rule can reason about is a cell: it has
; a floor, a size and one owner. A place is what a lane knows ("the pub", "my bedroom"),
; and turning one into the other needs a look at the world, which is exactly what enter
; does and go must not.
;
; TWO PHASES, one threshold, and the same rule everywhere in the movement lanes: outside
; near_building_m he heads for the SHAPE and reserves nothing, because a cell held from
; across town is a cell taken from whoever is standing in it; inside it he CLAIMS, and
; finishes on whatever he actually got. The claim is the rung's, released when the rung
; ceases.
;
; enter is a TASK and not an action because crossing the shell of a structure is work in
; its own right: the door may be shut, locked or barred, and the entrance may have to be
; located first. So it can genuinely FAIL - calling on a friend who is not home leaves you
; outside a locked door - and it SUCCEEDS when @self is in fact inside.
;
; The near leg WALKS rather than proposing go, and that is load-bearing: go hands a cell
; inside a building back to enter, so if enter answered with go again the two would recur.
; It does not need go - a structure's rooms are one navmesh island reached through its door
; passages, so the threshold is a single leg.
;
; A CLOSED venue at the threshold matches no rung, so the task stalls rather than lying:
; the locked-door / key / force-entry rungs plug in here.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

; INSIDE, as the place's own kind means it: a structure holds him at its building rung, a
; space holds him directly. Written once and read three times - the gate, the cease, and
; the rungs that must not fire once he is in.
(define-func is-inside (?place)
  (or (and (is-a ?place [k structure]) (spatial @self building ?place))
      (spatial @self space ?place)))

(npc-task {@self enter ?place}:?enter-rel
  (tar @excl [k structure|space] @object)
  ; The venue's box is read from ground truth on the coarse leg: a bounds read is a
  ; perception signal, and a venue he is still walking toward is one he cannot yet see.
  (lint-waive env-read-outside-action)
  ; THE CONDITION THE TASK RUNS UNDER, its own and no proposer's: he is not in yet. It
  ; joins every rung's gate, and the moment the barrier is crossed it stops holding, so
  ; enter concludes on its own terms rather than waiting to be torn down from outside.
  (when (not (is-inside ?place)))
  ; ...and the one test serves both endings. Crossed: /succ. Called off mid-approach: the
  ; withdrawal runs this too, at the last moment the record is still open, and says
  ; nothing - leaving the /interrupted the withdrawal stamps, which is the truth.
  (cease (if (is-inside ?place) (then (set-outcome ?enter-rel /succ))))
  (and
    ; UNPLACED, and the house at its premises is one he HAS seen: walk in. A room is only
    ; ever seen from INSIDE a building, so entering is what places it - and an address is
    ; the only thing a page can carry about a place.
    (try
      (role @self {?place address ?a} (address-premises ?a): ?pa
        (role ?house [k building] (observed ?house) {?house address ?pa}
          (when (and (not (grounded ?place))
                     (not (spatial @self building ?house))))
          (effects (maintain-proposal {@self enter ?house})))))
    ; UNPLACED and already INSIDE that house: walking in taught him the entrance, not every
    ; room. Tour it until the room itself is placed, which drops this rung and raises the
    ; legs below.
    (try
      (role @self {?place address ?a} (address-premises ?a): ?pa
        (role ?house [k building] (observed ?house) {?house address ?pa}
          (when (and (not (grounded ?place))
                     (spatial @self building ?house)))
          (effects (maintain-proposal {@self locate ?place ?house})))))
    ; UNPLACED and no house he has seen stands at that premises: search the region
    ; structure by structure. The search's own /fail record ends the hunt once every
    ; structure is seen.
    (try
      (role @self {?place address ?a} (address-premises ?a): ?pa
        (when (and (not (grounded ?place))
                   (unsubstantial (seen-premises-at ?pa))
                   -{@self find-building ?place ? /fail}
                   (current-exterior @self): ?rg))
        (effects (maintain-proposal {@self find-building ?place ?rg}))))

    ; PLACED and FAR - a structure is approached, which lands him before its front face
    ; without reserving anything inside it.
    ;
    ; FAR is the NEGATION of near, never a >= of its own. A mind is GROUNDED on anything it
    ; internalized, and a GROUNDED object can still have no box at all: an unnamed church
    ; he holds an object for answers @unknown to (distance ..), where a church he has met
    ; answers metres. @unknown fails a >= and a < alike, so a FAR side written as its own
    ; >= leaves every rung of this task dead. A distance he cannot measure is not NEAR, so
    ; it belongs here, and the approach reads the world's own box to get him there.
    (try
      (when (poll (grounded ?place)
                  (is-a ?place [k structure])
                  (not (< (distance @self ?place) (near_building_m)))))
      (effects (maintain-proposal {@self approach ?place})))
    ; PLACED and FAR - a space is headed for. (env-cell ..) picks a spot and claims
    ; nothing, so many men can be bound for the same room without contending.
    (try
      (when (poll (grounded ?place)
                  (not (is-a ?place [k structure]))
                  (not (< (distance @self ?place) (near_space_m)))))
      (effects
        (travel-cell ?place): ?spot
        (if (is-cell ?spot) (then (maintain-proposal {@self go ?spot})))))

    ; AT THE HULL and not yet on a stand cell: claim one BEFORE THE FRONT FACE - ground he
    ; is standing on, so the grid has it - and walk onto it.
    ;
    ; The claim sits in a POLL and not in effects, and that is load-bearing. A claim can
    ; answer "waiting for chunk": the env grid loads asynchronously and a pending claim
    ; stays pending (Marcus 2026-09-20), so the rule must RE-ASK until a real cell comes
    ; back. A poll re-tests every cycle and does exactly that. In effects the @fail aborts
    ; the rung once and nothing ever asks again - the man stands outside his own house for
    ; the rest of the year.
    (try
      (when (poll (grounded ?place)
                  (is-a ?place [k structure])
                  (< (distance @self ?place) (near_building_m))
                  (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?place]
                                           [/at_or_near @self]): ?stand
                  (not (overlaps ?stand @self))))
      (effects (maintain-proposal {@self WALK ?stand})))
    ; ON that cell, the venue open: step inside. The first room is read from ground truth
    ; and OBSERVED - standing at the door is how a man learns what is behind it - and
    ; entering THAT room is an ordinary enter on a space, whose own near leg claims a floor
    ; cell with the grid now loaded around him.
    (try
      (when (poll (grounded ?place)
                  (is-a ?place [k structure])
                  (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?place]
                                           [/at_or_near @self]): ?stand
                  (overlaps ?stand @self)))
      (when -{?place struct-status [k closed]})
      ; A WALK and NOT a nested enter: enter is (tar @excl ..), one to a mind, so an enter
      ; on the room could never start while this one on the building still holds the slot -
      ; the pair would wait on each other for ever. The cell is ENCODED from the room
      ; (travel-cell touches no grid), so there is nothing to wait for either.
      (effects
        (head (spatial ?place parts [k interior-space] /env)): ?way
        (observe ?way): ?seen-way
        (travel-cell ?seen-way): ?spot
        (if (is-cell ?spot) (then (maintain-proposal {@self WALK ?spot})))))
    ; NEAR a space: claim on its floor and take the last paces onto what he got. Poll for
    ; the same reason - the floor's chunk may still be loading.
    (try
      (when (poll (grounded ?place)
                  (not (is-a ?place [k structure]))
                  (< (distance @self ?place) (near_space_m))
                  (maintain-claim-env-cell (env-cell-size @self) [/on_floor_of ?place]
                                           [/at_or_near @self]): ?cell))
      (effects (maintain-proposal {@self WALK ?cell})))))
