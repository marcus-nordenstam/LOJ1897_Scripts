; ----------------------------------------------------------------------------
; realization_macros.hs - the destruction-realization contract + its date reads,
; as pure .hs over the generic primitives (end-beliefs-about / begin-belief /
; (any ..).start / date math). See docs/memory/memory_system.md section 13.
; ----------------------------------------------------------------------------

; (realize-destroyed ?item ?rel [k ?rel <value>]): the deliberating self REALIZES
; ?item is gone for good - their OWN act just destroyed it (the eaten meal, the
; buried corpse, the burned letter). Ends every ongoing belief about the item in
; @self's mind EXCEPT the standing @excl body-state axes (condition + internment
; - a tense flip, never a forget: "it WAS in the larder" stays as episodic
; history), then mints the ongoing state on the named @excl axis (?rel ?state):
; condition consumed for a prop, internment buried for a corpse. @excl supersedes
; any prior value on that axis (buried over unburied), while the OTHER axis
; (condition dead) stands. A pure SELF-MIND write - bystanders keep their stale
; beliefs until their own perception / a propagation rule closes them. Run
; BEFORE (destroy-entity ...).
(define-macro realize-destroyed (?item ?rel ?state)
  (do
    (end-beliefs-about ?item (exclude condition internment) /reason destroyed)
    (begin-belief {?item ?rel ?state})))

; (months-since-death ?c): whole months since THIS mind learned of ?c's death -
; the interval-start of @self's own ongoing {?c condition dead} belief. 0 when
; @self holds no such belief. Observer-side and telepathy-honest by construction
; (only known deaths count); date fields are 0-indexed consistently across
; (date_now) and the stored belief start, so the month diff needs no alignment.
(define-macro months-since-death (?c)
  (if (any {?c condition [k dead]})
      (then (max 0 (+ (* 12 (- (year (date_now))
                         (year (any {?c condition [k dead]}).start)))
                (- (month (date_now))
                   (month (any {?c condition [k dead]}).start)))))
      (else 0)))
