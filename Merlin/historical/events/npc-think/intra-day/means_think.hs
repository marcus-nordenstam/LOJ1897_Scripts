; ----------------------------------------------------------------------------
; means - the npc-THINK half: the DESIRE that arms a weapon-gated killer.
; A killer holding a method_means it does not yet control pushes utility onto the
; standing {@self acquire [k <means>]} goal so it promotes to acquire_act.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/possession_macros.hs")

; The DESIRE: a killer who holds a method_means it does not yet control resolves to
; obtain it. Binds the required tool kind off its own belief and pushes utility 90
; onto the standing {@self acquire [k <means>]} goal (the killer's memory of setting
; out to arm), which - the leaf - promotes to acquire_act. A maintenance event: it
; ceases (ends the acquire goal) the moment the killer controls the tool
; (real-possession termination), the falling edge of (not (control ?means)). NO (log) here - this
; fires in the deliberation pass; the acquisition is narrated at completion.
(npc-think means_plan_acquire
  (schedule on-changed {@self method_means ?})           ; fires when the killer forms a method_means
  (role @self (believes {@self method_means ?means}))    ; binds the required tool kind, cached
  (when (not (control ?means)))
  (utility 90)
  (effects       (begin-goal {@self acquire ?means}))
  (cease-effects (end-goal   {@self acquire ?means})))

; TERMINAL step (act_body_purification): the obtain is now PROPOSED, guarded by not yet controlling the
; means - the same gate the desire above uses (acquire_act absorbs the round-trip travel, so there is no
; separate arrival condition). Utility 90 mirrors the desire's drive. Reactive: re-proposes each decision
; point while the killer still lacks the tool; once controlled the desire's cease ends the goal and this
; stops firing.
(npc-think means_acquire
  (schedule always)
  (goal {@self acquire ?means})
  (when (not (control ?means)))
  (utility 90)
  (effects (propose {@self acquire ?means})))
