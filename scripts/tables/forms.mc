; ----------------------------------------------------------------------------
; forms - the FORMS a document is written as: a table with no records, whose fields
; are the rows every paper of that form carries. Written by (table-msg <form> ..),
; read by (form-match <paper> <form> ..).
; ----------------------------------------------------------------------------

(define-table job_posting_form
  (fields job-kind org-name job-id apply-at))

(define-table application_form
  (fields applicant home job-kind org-name job-id date))

(define-table offer_letter_form
  (fields applicant job-kind org-name job-id level salary shift))

(define-table rejection_letter_form
  (fields applicant job-kind org-name job-id))

(define-table invitation_letter_form
  (fields occasion-kind host venue held-on from-hour to-hour))


; A building's TITLE DEED, filed on the land registry's stack. Its owners are entries: a
; transfer strikes the current ones out and writes the new one under them, so the page is the
; building's whole history and the unstruck entries are who owns it now. is-org says whether
; the owner named is an organisation or a person.
(define-table title_deed_form
  (fields building (owners owner is-org struck)))

; An org's ARTICLES OF INCORPORATION, filed at the company registry. The register cell is the
; KIND of book the org keeps; the book itself carries the org's name. Its owners are entries,
; as on a deed.
(define-table articles_form
  (fields org-kind org-name workplace register (owners owner is-org struck)))
