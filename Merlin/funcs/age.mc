; ----------------------------------------------------------------------------
; age.mc - the yearly age stamp.
;
; age-band and age-span are (per obs) (auto-percept) attrs, so the moment they are
; WRITTEN the self-perceive pass mirrors them into {@self age-band <band>} and
; every observer internalizes them on sight. Nothing else has to mint anything.
;
; They were written by refresh_all_age_attrs, which was stripped as content in the
; C++ migration and never rewritten - so for as long as that hole stood, no NPC in
; the parish had an age at all, and every rule gating on a band (most of the
; social corpus: courtship, betrothal, affairs, conception, immigration) could
; never match. This file is that function, as content.
;
; It runs on each person's BIRTHDAY, registered with (register-annual-func ..) when they are
; created, and once more at creation so nobody waits a year for their first band.
; ----------------------------------------------------------------------------

(define-func refresh-age-band (?h)
  (age (attr ?h birth-date)): ?yrs
  (bind @nothing ?band)
  (bind @nothing ?span-lo)
  (bind @nothing ?span-mid)
  (bind @nothing ?span-hi)
  ; The rows ascend, so the LAST row the age has reached is the band - no
  ; comparison against an upper bound, and adding a band is a row, not a branch.
  (for-each-row age_bands
      [/band ?b] [/min-age ?mn] [/span-lo ?sl] [/span-mid ?sm] [/span-hi ?sh]
    (if (>= ?yrs ?mn)
      (then
        (bind ?b ?band)
        (bind ?sl ?span-lo)
        (bind ?sm ?span-mid)
        (bind ?sh ?span-hi))))
  (if (substantial ?band)
    (then
      (set-attr ?h age-band ?band)
      ; The span is a plural attr, so last year's window has to come off before
      ; this year's goes on. Dropping every band is idempotent and costs eight
      ; removes a year; tracking which three were there would not be cheaper.
      (for-each-row age_bands [/band ?old]
        (remove-attr-item ?h age-span ?old))
      (add-attr-item ?h age-span ?span-lo)
      (add-attr-item ?h age-span ?span-mid)
      (add-attr-item ?h age-span ?span-hi))))

; ----------------------------------------------------------------------------
; start-aging - stamp a new person's band now and book the yearly re-stamp on
; their birthday. Called by every creation path: the founder pass, the immigrant
; arrival, and a birth.
; ----------------------------------------------------------------------------

(define-func start-aging (?h)
  (refresh-age-band ?h)
  (attr ?h birth-date): ?bd
  (register-annual-func (month ?bd) (day ?bd) refresh-age-band ?h))
