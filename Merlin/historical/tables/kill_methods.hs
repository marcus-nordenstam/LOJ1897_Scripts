; ----------------------------------------------------------------------------
; kill_methods.hs - the method-CHOICE rows choose_kill_method.hs crosses with
; the actor's standing kill goals (select-joint). `means` names the control
; kind the method needs ([k ...] arms the means_cascade acquisition; `none`
; = bare hands / no tool); `weight` is the base preference;
; `strength_demand` gates the physical methods (a weak actor discounts them).
;
; DELIBERATELY ABSENT until their execution passes exist:
;   poison [k toxin]  - needs the chronic-dosing meal pass (Docs/future_work
;                       "kill-lane method choice"); a chosen-but-unexecutable
;                       method would stall its killer forever.
;   staged methods    - same (drown / freeze / push_from_height / death_trap).
; The fight lane executes every CHOSEN method today: an armed method's
; acquisition (firearm) upgrades the melee the fight lane already runs.
; ----------------------------------------------------------------------------

(define-table kill_method_choice
  (fields method means weight strength_demand)
  (record strangle           none        1.0 0.45)
  (record shoot              [k firearm] 0.8 0.10)
  (record commission_killing none        0.5 0.00))
