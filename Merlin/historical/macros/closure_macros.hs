; ----------------------------------------------------------------------------
; closure_macros.hs - the no-telepathy business-teardown primitives.
;
; A closing owner NEVER writes a worker's mind. Instead he sets a PERCEIVABLE
; physical fact on the workplace BUILDING - the doors are shuttered - and workers
; reconcile their own stale employment beliefs when they turn up and find it shut
; (rules/npc-think/reconcile_closed.hs). This is the primary no-telepathy
; coordination channel (perception at co-presence), not a mind edit.
;
; (shutter-building ?wp): shutter the premises ?wp by writing its struct_status = [k closed]
; (a perceivable physical fact on the BUILDING, shared/attrs.arc). Since NPCs always front-
; park a building on arrival, a worker RE-OBSERVES it every commute and INTERNALIZES
; {?wp struct_status [k closed]} fresh, and reconcile_closed drops his own stale employment
; beliefs off that PERCEIVED belief - no mind but his own is written. MARK, not destroy:
; the building stays in the world so workers can perceive the state. Content-free and
; general - any closure act (business_failure, dissolution) calls it on the premises.
; ----------------------------------------------------------------------------

(define-macro shutter-building (?wp)
  (set-attr ?wp struct_status [k closed]))
