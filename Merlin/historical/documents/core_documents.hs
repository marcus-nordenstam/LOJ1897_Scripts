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

; The org roster: a list-of-records doc, one (worker job) record per employee.
(define-document employee_register (fields worker job))
