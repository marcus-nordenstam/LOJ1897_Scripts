; ----------------------------------------------------------------------------
; reconcile_closed - the GENERAL point-of-use correction for a shuttered workplace
; (the linchpin of the no-telepathy teardown model).
;
; A business owner who closes his firm does NOT reach into his workers' minds. He
; sets a PERCEIVABLE physical fact on the workplace building - (shutter-building
; ?wp), a `closed` env attr (macros/closure_macros.hs) - and destroys HIS OWN
; incorporation docs. Each worker still holds his stale {@self employer ?org} /
; {@self job ?job} beliefs and, not yet knowing, still commutes to the premises
; during his shift (work_attendance.hs). THIS rule is what he learns on turning up:
; standing AT the shuttered building he reads its `closed` state and drops his own
; employment beliefs - freeing him to re-seek work via the existing hiring lane
; (employment.hs gates on (not (believes {@self employer ?}))).
;
; KNOWLEDGE-HONEST BY PERCEPTION. The worker's daily commute (work_attendance.hs) now
; FRONT-PARKS his workplace building (the Stage-5 two-arm always front-parks a building on
; arrival), so exterior perception RE-OBSERVES it every commute and internalizes {?wp
; struct_status [k closed]} fresh. The rule reads that PERCEIVED belief (not an env attr).
; He is not told; he sees the doors shut from the street. No mind but his own is written.
;
; GENERAL: no org, job, or NPC is baked in. The employer / workplace / job chain
; is the SAME one work_attendance.hs binds ({@self employer ?org} -> {?org
; workplace ?wp}, plus {@self job ?job}); every conjunct is a live belief read.
;
; The same "my referent is gone, drop the belief" shape generalises to other
; closed/demolished referents (a razed home, an ended tenancy) - each its own
; minimal rule over the perceivable fact. Only the employer/closed-workplace
; reconciliation is built here; the rest are left to their own teardown lanes.
;
; LANE: (short-term-think) - re-evaluated each intra-day deliberation, so it fires
; the cycle he is at the shuttered premises. (cont-fire-effects ...): ending the
; employer belief makes the (bind {@self employer ?org}) conjunct fail next cycle,
; so the gate self-extinguishes after one firing (no first-fire latch needed). No
; goal / utility: the effects just end beliefs when the gate holds (they do not
; compete for the motor).
; ----------------------------------------------------------------------------

(npc-think reconcile_closed
  (short-term-think)
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (bind {@self job ?job})
             (believes {?wp struct_status [k closed]})))
  (cont-fire-effects
    (end-belief {@self employer ?org})
    (end-belief {@self job ?job})))
