; ----------------------------------------------------------------------------
; orient_errand - the npc-ACT half of new_job_orientation.
;
; @self holds {@self goal {@self ORIENT}}. He routes to the parish church (the
; common civic space) and, once there, reads the PUBLIC register of incorporations:
; for every articles_of_incorporation document he forms / recalls its org object and
; mints the kind / founder / record beliefs that let the belief-pure casting rules
; role over it. (documents [k ...]) is a public-register read in an act effect (not
; a role filter), so it stays off the per-candidate cache path; the minted beliefs
; are mental writes, safe inside the document walk (no entity create / destroy).
;
;   orient_go    : hold the goal, not at a church -> travel to one.
;   orient_dwell : hold the goal, at a church -> a short dwell (reading the register).
;   orient_read  : completion - read the register + clear the goal.
; ----------------------------------------------------------------------------

(npc-action {@self ORIENT}
  (duration 30)
  (effects
    ; READ the public register: per articles document, ADOPT its writing - the
    ; constitutive (written-msg {?org isa..} {?org founder..} {?org workplace..}
    ; {?org name..}) sentences. Each ?org REG-externalized to its NAME on the page,
    ; so adopting reconstructs the reader's OWN org object (by name) with the
    ; queryable beliefs the casting filters read. This is the sanctioned "read a doc
    ; to learn what you don't know" path - a stranger learning the town's orgs.
    (for-each ?art (documents [k articles_of_incorporation])
      (do (adopt-msg (attr ?art writing))))
    (set-outcome {@self ORIENT} succ)))
