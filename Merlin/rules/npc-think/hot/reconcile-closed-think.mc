; ----------------------------------------------------------------------------
; reconcile_closed - the GENERAL point-of-use correction for a shuttered workplace
; (the linchpin of the no-telepathy teardown model).
;
; A business owner who closes his firm does NOT reach into his workers' minds. He
; sets a PERCEIVABLE physical fact on the workplace building - (shutter-building
; ?wp), a `closed` env attr (macros/closure_macros.hs) - and destroys HIS OWN
; incorporation docs. Each worker still holds his stale {@self job ?job} beliefs
; and, not yet knowing, still commutes to the premises
; during his shift (work_attendance.hs). THIS rule is what he learns on turning up:
; standing AT the shuttered building he reads its `closed` state and drops his own
; employment beliefs - freeing him to re-seek work via the existing hiring lane
; (employment.hs gates on (none {@self job.salary ?})).
;
; KNOWLEDGE-HONEST BY PERCEPTION. The worker's daily commute (work_attendance.hs) now
; FRONT-PARKS his workplace building (the Stage-5 two-arm always front-parks a building on
; arrival), so exterior perception RE-OBSERVES it every commute and internalizes {?wp
; struct-status [k closed]} fresh. The rule reads that PERCEIVED belief (not an env attr).
; He is not told; he sees the doors shut from the street. No mind but his own is written.
;
; GENERAL: no org, job, or NPC is baked in. The job / org / workplace chain
; is the SAME one work_attendance.hs binds ({@self job.org ?org} -> {?org
; workplace ?wp}, plus {@self job ?job}); every conjunct is a live belief read.
;
; The same "my referent is gone, drop the belief" shape generalises to other
; closed/demolished referents (a razed home, an ended tenancy) - each its own
; minimal rule over the perceivable fact. Only the org/closed-workplace
; reconciliation is built here; the rest are left to their own teardown lanes.
;
; This rule fires the cycle he is at the shuttered premises. Ending the job belief makes
; the (role ?org {@self job.org ?org}) gate fail next cycle, so the rule
; self-extinguishes after one firing. No goal / utility: the effects just end
; beliefs when the gate holds (they do not compete for the motor).
; ----------------------------------------------------------------------------

; The firing condition is perceiving {?wp struct-status closed} at the premises. This
; belief is about ?wp (the workplace), not @self, and lives in the (when). Cheap: gated
; to employed workers, and ends its own gate on first fire.
(npc-think reconcile_closed
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             {?org workplace ?wp})   ; ?wp binds at fire
  (when (and {?wp struct-status [k closed]}))
  (effects
    (end-belief {@self job ?job})))
