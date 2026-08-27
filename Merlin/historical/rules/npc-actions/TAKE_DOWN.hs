; ----------------------------------------------------------------------------
; take_down - the clerical WRITE act of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Pen-changes-paper: a posting comes
; off the board. An org is a mental-only object and never an act participant -
; every participant is paper or people.
;
; RECRUITER: take a filled posting off the board - the paper is removed.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self TAKE_DOWN ?ad}
  (duration 5)
  (effects
    (destroy-entity ?ad)
    (set-outcome {@self TAKE_DOWN ?ad} succ)))
