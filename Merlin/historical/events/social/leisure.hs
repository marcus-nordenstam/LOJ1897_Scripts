; ----------------------------------------------------------------------------
; Leisure (Phase 6 leaf events). dinner_party only.
;
; The old pub_regular_started / theatre_attendance_started seeds (which minted a
; one-shot static {@self frequents <building>}) were retired in the activity-
; lanes L8 frequents retirement: frequenting is now EMERGENT from the activity
; lanes - vice (indulge@pub), interest (pursue@venue), social-outing
; (socialize_at@venue), worship (worship@church). The classifiers that read the
; old haunt now derive the "is a regular" signal from those activity memories.
;
; dinner_party stays: it is a believe-about refresh among the married, not a
; frequents writer.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- dinner_party: a married adult hosts a friend for dinner ---------------
(hsim-event dinner_party
  (nl         "?host hosts ?guest for dinner")
  (kind       _dinner_party)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the residential_building
  ; `dinner_party` affordance among the gathered guests (place-lane).
  (band      evening)
  (rng-stream behaviour)

  (roles
    (role ?host  (template old_human)
                 (believes ?self {@self spouse ?}))
    (role ?guest (template any_human)
                 (not (= ?self ?host))
                 (believes ?host {@self friend ?guest})
                 ; Place model: the friend must be AT the dinner - co-present at
                 ; the host's home (run_gatherings brings them). Fired by the
                 ; residential_building `dinner_party` affordance, so the
                 ; per-occasion chance lives on the affordance, not here.
                 (co-present ?host ?guest)))

  (effects
    (believe-about ?host ?guest)
    (log _dinner_party ?host)))
