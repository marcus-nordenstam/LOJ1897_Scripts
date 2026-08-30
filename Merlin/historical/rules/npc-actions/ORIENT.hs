; ----------------------------------------------------------------------------
; orient_errand - the npc-ACT half of new_job_orientation.
;
; @self holds {@self goal {@self ORIENT}}. He routes to the parish church (the
; common civic space) and, once there, reads the PUBLIC register of incorporations:
; for every articles_of_incorporation document he forms / recalls its org object and
; mints the kind / founder / record beliefs that let the belief-pure casting rules
; role over it. (env-entities [k ...]) is a public-register read in an act effect (not
; a role filter), so it stays off the per-candidate cache path; the minted beliefs
; are mental writes, safe inside the document walk (no entity create / destroy).
;
;   orient_go    : hold the goal, not at a church -> travel to one.
;   orient_dwell : hold the goal, at a church -> a short dwell (reading the register).
;   orient_read  : completion - read the register + clear the goal.
; ----------------------------------------------------------------------------

(include "../../macros/adopt-aoc.hs")

(npc-action {@self ORIENT}
  (duration 30)
  (effects
    ; READ the public register: per articles document, decode its TABLE into beliefs
    ; via (adopt-aoc) - the org object (anchored to the articles) + its queryable
    ; {?org isa/name/founder/workplace/register} beliefs the casting filters read. This
    ; is the sanctioned "read a doc to learn what you don't know" path - a stranger
    ; learning the town's orgs.
    (for-each ?art (env-entities [k articles_of_incorporation])
      (adopt-aoc ?art))
    (set-outcome {@self ORIENT} /succ)))
