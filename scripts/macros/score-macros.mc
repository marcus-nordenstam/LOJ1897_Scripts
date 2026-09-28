; ----------------------------------------------------------------------------
; score_macros.mc - composable scoring/disposition macros for motive rules.
;
; Layered by design: small named readings nest into bigger named scores, so an
; rule's (when ...) / blame decision reads as intent, not arithmetic. Macros
; expand recursively at compile (a macro body may call other macros); every
; entity is passed BY ARGUMENT (?who / ?t), so the same reading works for
; @self, a role var, or a bound var at any call site.
;
; Belief reads run in the deliberating self's mind (the believes/target
; single-POV rule); (attr ...) reads env ground truth.
; ----------------------------------------------------------------------------

; --- Layer 0: numeric / belief primitives -----------------------------------




; --- Layer 1: single-quantity readings ---------------------------------------






; The warmth at or below which the self detests someone.
(define-macro detest-warmth-max () -2.0)





; --- Layer 1: named trait tails (who is CAPABLE of what) --------------------



; --- Layer 2: the propensity product -----------------------------------------

; The global crime-rate throttle every aggressive-category (chance ...) multiplies
; by. Set to 0 to switch crime off cleanly: the deliberation outlet then fails its
; (> (crime-scale) 0) gate and shuts off (see deliberate_think).
(define-macro crime-scale ()
  0.1)



; --- Layer 3: betrayal blame (betrayal_kill.mc) ------------------------------







