; ----------------------------------------------------------------------------
; role_macros.hs - role-clause readability macros.
;
; (pick-first-matching-role): reduce a role to its FIRST matching candidate
; instead of firing per-candidate. Expands to (select (score 1)): a constant
; score under the default argmax policy keeps the first max it meets, so the
; binder takes the first candidate in pool order and stops. Use it when the role
; is expected to be singular (a paramour, a partner) or when WHICH match is not
; load-bearing - it names the intent that (select (score 1)) leaves implicit.
; ----------------------------------------------------------------------------

(define-macro pick-first-matching-role ()
  (select (score 1)))
