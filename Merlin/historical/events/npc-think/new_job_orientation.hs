; ----------------------------------------------------------------------------
; new_job_orientation - the discovery half of the belief-pure org-casting model.
;
; The casting events (hiring / club_joining / apprenticeship_start /
; business_partnership / senior_appointment) used to role-enumerate EVERY
; articles_of_incorporation in the world (the (kind ...) / org-kind-is-a omniscient
; ops). They now role only over orgs @self ALREADY KNOWS - cached mental org
; objects carrying an isa belief. This event is how a townsperson comes to know the
; orgs: he goes to the parish (the common civic space everyone attends) and reads
; the PUBLIC register of incorporations there, forming one mental org object per org
; (isa / founder / record beliefs). Incorporations are public record, so this is an
; honest read - no telepathy, and no omniscient world-scan in any role filter (the
; register read lives in the act effect, not a per-candidate role filter).
;
; THINK (here): a townsperson of working age resolves to consult the register.
; ACT (orient_errand.hs): routes him to the church and the completion reads it.
;
; Not org heads (they already know their own org). The per-month (chance) keeps it
; periodic so newly-founded orgs are picked up over time (idempotent re-reads -
; imagine-or-recall recalls the existing object, begin-belief is idempotent). age /
; job-level / chance are non-belief ops, so they gate the fire in (when).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour new_job_orientation
  (long-term-think)
  (rng-stream employment)

  ;; Only the JOBLESS consult the register - this is a JOB SEARCH. A man already in
  ;; a post does not go reading the vacancies. The jobless filter is a belief-pure
  ;; self-role criterion, so the @self enumeration itself caches.
  (roles
    (role @self (any_human @self)
                (not (believes {@self employer ?}))))

  (when (and (>= (years-old @self) 12)
             (chance 0.3)))

  (effects
    (begin-goal {@self orient})))
