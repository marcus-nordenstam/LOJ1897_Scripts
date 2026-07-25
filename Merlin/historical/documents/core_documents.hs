; ----------------------------------------------------------------------------
; core_documents.hs - document record schemas (define-document).
;
; A document's writing is a record of named fields; a field's INDEX is its
; position here. The doc-record ops ((read-doc-record ...) etc.) resolve their
; field names to these indices at parse, via the leading [k <kind>] cast.
;
; These schemas MUST match the C++ writers' slot order while those writers remain
; in C++ (hsim_org_lifecycle.h k_articles_*_slot): the schema is the read side of
; a contract the C++ write side still owns until the write ops land (Phase 2+).
; ----------------------------------------------------------------------------

; The org anchor: [kind founder building year register]
;   (hsim_org_lifecycle.h k_articles_kind/founder/building/.../register_slot = 0/1/2/3/4)
(define-document articles_of_incorporation (fields kind founder building year register))

; The org roster: a list-of-records doc, one (worker job level) record per
; employee. `level` is the starting rank kind ([k senior] / [k apprentice] /
; ...), written alongside worker + job so the materialize_employment event can
; reconstruct the employment beliefs from the roster alone (the beliefs live in
; .hs; the roster, objective, is written by the thin C++ enrol verb / hire-seq).
; A club membership entry carries only (member membership) - no level.
(define-document employee_register (fields worker job level))

; ----- property register schemas --------------------------------------------
; The housing-market documents the property register files. Slot order matches the
; C++ writers in hsim_property.cc (k_building_slot = 0, k_deed_owner_slot = 1):
;   list_on_market  writes a listing record of just [building];
;   register_ownership writes the title_deed record [building owner].
; The Phase-1 housing / landlord read events role / for-each over these by kind.
;
; A dwelling offered for purchase: [building]
(define-document for_sale_listing  (fields building))
; The registry ownership record: [building owner]
(define-document title_deed        (fields building owner))
; A dwelling offered to let: [building]
(define-document for_lease_listing (fields building))
