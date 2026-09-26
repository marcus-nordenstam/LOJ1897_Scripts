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
