; ----------------------------------------------------------------------------
; means - the DRIVER that arms a shooter. A killer running the shoot task who holds no
; firearm PROPOSES the acquire task for one - covertly, since an armed murder wants no
; purchase record tracing back to it. The acquire task (acquire-task.hs) picks the
; method (a covert acquisition routes to hiring a procurer, else stealing) and drives
; it down to the shop. Maintain-proposed, so it withdraws the instant the killer
; controls a firearm (the falling edge of the empty-grip test) or the kill intent dies.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think shoot_arm
  (task {@self shoot ?})
  (role @self)
  (when (empty (spatial @self hold [k firearm])))
  (utility errand always-pick)
  (effects (maintain-proposal {@self acquire [k firearm] [k covert]})))
