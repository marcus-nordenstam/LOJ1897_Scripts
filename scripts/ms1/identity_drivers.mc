; ----------------------------------------------------------------------------
; identity_drivers.mc - patterns that mark @self-beliefs as identity-bearing,
; as a .mc define-table parsed by the shared list/table coordinator.
;
; The runtime is_identity_driver / identity_driver_weight test a committed
; belief against these rows; only {@self <label> [<target>]} beliefs match. A
; matched belief contributes `weight` to Phase 9's identity-anchor accumulator.
;
; Columns: label (belief relation label), weight (identity contribution),
; tar (optional target-kind filter; `_` = any). System 1 tuning.
; ----------------------------------------------------------------------------
(define-table identity_driver (fields label weight tar)
  ; Foundational kin (the inherited part of identity).
  (record mother       0.7 _)
  (record father       0.7 _)
  (record child        0.7 _)
  (record sibling      0.5 _)
  (record cousin       0.3 _)
  ; Romantic / chosen bonds.
  (record spouse       0.7 _)
  (record lover        0.5 _)
  (record friend       0.3 _)
  ; Held values + loyalties.
  (record identity     1.0 _)
  (record value        0.8 _)
  (record admire       0.4 _)
  (record revere       0.4 _)
  ; Occupation / role.
  (record job          0.6 _)
  (record social_class 0.6 _)
  (record nationality  0.5 _)
  ; Origin + dwelling.
  (record birthplace   0.4 _)
  (record home         0.4 _)
  ; Long-burn pressures (residual identity load).
  (record pressure     0.3 _))
