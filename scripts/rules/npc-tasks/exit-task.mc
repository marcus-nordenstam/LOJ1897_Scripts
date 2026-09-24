; ----------------------------------------------------------------------------
; exit - the twin of enter: get @self out of a structure and onto the street.
;
; ONE rung, because leaving needs no route planning of its own. A structure's rooms are
; one navmesh island and its doors are passages, so from any room in it a cell on the
; street is a single leg - the funnel finds the doorway. Walking him to the entrance and
; then out again would be the rule doing by hand what the nav graph does by construction,
; and it would strand him the moment a building had no entrance entity authored.
;
; The box the cell is claimed against is the one he REMEMBERS, which he certainly has: he
; is standing inside it. So there is no ground-truth read here and nothing to waive.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; STILL IN IT, written once and read twice: as the condition the task runs under, and in
; the cease that says what stopping meant.
(define-func still-in (?bldg)
  (spatial @self building ?bldg))

(npc-task {@self exit ?bldg}:?exit-rel
  (tar @excl [k container-structure] @object)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (grounded ?bldg))
    (check (still-in ?bldg)))
  (when (still-in ?bldg))
  (cease (if (not (still-in ?bldg)) (then (set-outcome ?exit-rel /succ))))
  (try
    (when (poll (maintain-claim-env-cell (env-cell-size @self) [/in_front_of ?bldg]
                                         [/at_or_near @self]): ?cell))
    (effects
      (check (is-rel-cell ?cell))
      (check (= (cell-anchor ?cell) ?bldg))
      (maintain-proposal {@self WALK ?cell}))))
