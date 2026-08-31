; ----------------------------------------------------------------------------
; new_job_orientation - the discovery half of the belief-pure org-casting model.
;
; The casting rules (hiring / club_joining / apprenticeship_start /
; business_partnership / senior_appointment) used to role-enumerate EVERY
; articles_of_incorporation in the world (the (kind ...) / org-kind-is-a omniscient
; ops). They now role only over orgs @self ALREADY KNOWS - cached mental org
; objects carrying an isa belief. This rule is how a townsperson comes to know the
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
; chance are non-belief ops, so they gate the fire in (when).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think new_job_orientation
  (cooldown 1 m)
  (rng-stream employment)

  ;; Only the JOBLESS consult the register - this is a JOB SEARCH. A man already in
  ;; a post does not go reading the vacancies. The jobless filter is a belief-pure
  ;; self-role criterion, so the @self enumeration itself caches.
  (role @self
              -{@self job ?})

  ; MAINTENANCE (blessed days-since-last pattern, like want_drink): mint the shared orient goal;
  ; the (chance) is the ONSET roll (latch-eval locks it once holding); (days-since-last orient)
  ; is the CONTINUOUS completion gate - orient_act ends its {@self ORIENT} act-belief at the read,
  ; so days-since resets to 0, the (when) drops, and the goal ends after one read (no re-read
  ; storm). The cooldown + chance re-arm the periodic re-read, so new orgs are still picked up.
  (when (and (>= (years-old @self) 12)
             (>= (days-since-last {@self ORIENT /ever}) 1)
             (latch-eval (chance 0.3))))

  (utility errand)
  (effects       (begin-goal {@self ORIENT}))
  (cease-effects (end-goal   {@self ORIENT})))
