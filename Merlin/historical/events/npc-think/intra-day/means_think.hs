; ----------------------------------------------------------------------------
; means - the npc-THINK half: the DESIRE that arms a weapon-gated killer.
; A killer holding a method_means it does not yet control pushes utility onto the
; standing {@self acquire [k <means>]} goal so it promotes to acquire_act.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The DESIRE: a killer who holds a method_means it does not yet control resolves to
; obtain it. Binds the required tool kind off its own belief and pushes utility 90
; onto the standing {@self acquire [k <means>]} goal (the killer's memory of setting
; out to arm), which - the leaf - promotes to acquire_act. Stops firing the moment
; the killer controls the tool (real-possession termination). NO (log) here - this
; fires in the deliberation pass; the acquisition is narrated at completion.
(npc-think means_plan_acquire
  (short-term-think)
  (when (and (bind {@self method_means ?means})
             (not (controls @self ?means))))
  (utility 90)
  (cont-fire-effects (begin-goal {@self acquire ?means})))
