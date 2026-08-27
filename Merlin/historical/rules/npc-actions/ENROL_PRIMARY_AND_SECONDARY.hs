; ----------------------------------------------------------------------------
; schooling_errands (npc-action) - the ACT halves of the primary/secondary
; schooling-enrolment splits. The two acts are the SAME implementation, differing
; only by which curriculum kind they mint (the tier), so they share one file -
; mirrors LEFT_AND_RIGHT_PUT.hs.
;
; Each enrolment decision (schooling.hs enroll_primary / _secondary) minted
; {@self goal {@self ENROL_PRIMARY}} / {@self goal {@self ENROL_SECONDARY}}. The
; go/dwell think half lives in npc-think/schooling_errands.hs; these are the
; matriculation completions at the school. ENROL_UNIVERSITY lives in its own file
; (ENROL_UNIVERSITY.hs) - its curriculum pick is interest-led, not a bare mint.
; ----------------------------------------------------------------------------

; ----- primary -------------------------------------------------------------
(npc-action {@self ENROL_PRIMARY}
  (duration 60)
  (effects
    (begin-belief {@self study [k primary_school_curriculum]})
    (set-outcome {@self ENROL_PRIMARY} succ)))

; ----- secondary -----------------------------------------------------------
(npc-action {@self ENROL_SECONDARY}
  (duration 60)
  (effects
    (begin-belief {@self study [k secondary_school_curriculum]})
    (set-outcome {@self ENROL_SECONDARY} succ)))
