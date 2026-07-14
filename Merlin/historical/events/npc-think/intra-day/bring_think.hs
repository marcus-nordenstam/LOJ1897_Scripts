; ----------------------------------------------------------------------------
; bring (npc-think lane) - the GENERAL carry-it-to-a-place chain. A think that
; wants goods moved mints {@self bring <ware-kind> <dest>} (the acquisition
; already put the items in @self's hand); this lane drains it:
;
;   bring_go  : holding the goal, not at <dest> -> travel there (the same
;               destination-first shape as worship_go / drink_go).
; At <dest> the go sub-goal retires, the bring goal is the leaf, and the
; put-down act (npc-act/bring_act.hs) promotes on its own at-place when -
; never anywhere else, exactly like worship never happens outside the church.
; The MINTING desire owns the utility and boosts it at the destination.
;
; Content-free w.r.t. the ware: what is carried, where it goes, and when the
; goal is (re)minted is the MINTING lane's policy (provisioning brings food to
; the kitchen; nothing here presupposes food).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The go sub-goal INHERITS the bring goal's drive through /cause (worship_go
; shape) - the MINTING lane owns the utility (provisioning: provision_rearm 90).
(npc-think bring_go
  (short-term-think)
  (goal {@self bring ?ware ?dest})
  (when (and (not (under-attack))
             (not (at-place ?dest))))
  (cont-fire-effects (go-into ?dest)))
