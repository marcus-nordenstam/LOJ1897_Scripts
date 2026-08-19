; ----------------------------------------------------------------------------
; barbs.hs - RETIRED. The insult content model now lives inline in each insult
; driver as a (define-table barb_ladder) captured off that driver's ?victim role
; (bonded_incident_insult_think.hs, express_contempt_think.hs): the contexts are
; disjoint per driver, so each table is single-use. The old two-table model
; (barb_ladders + barb_materials) and its C++ scanner (hsim_barbs.cc/.h,
; compose_barb) are purged - a barb is now a belief @self already holds about the
; victim, read through the role's tolerant (any ...)/(lowest ...) captures.
; ----------------------------------------------------------------------------
