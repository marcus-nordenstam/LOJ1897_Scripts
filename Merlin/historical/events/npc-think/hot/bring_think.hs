; ----------------------------------------------------------------------------
; bring (npc-think lane) - the GENERAL carry-it-to-a-place chain. A think that
; wants goods moved mints {@self bring <ware-kind> <dest>} (the acquisition
; already put the items in @self's hand); this lane drains it:
;
;   bring_go       : holding the goal, not at <dest> -> travel there (the same
;                    destination-first shape as worship_go / drink_go).
;   bring_at_dest  : AT <dest> -> propose the put-down act (npc-act/bring_act.hs);
;                    goals never propose themselves. Off <dest> nothing fires,
;                    exactly like worship never happens outside the church.
; The MINTING desire owns the utility and boosts it at the destination.
;
; Content-free w.r.t. the ware: what is carried, where it goes, and when the
; goal is (re)minted is the MINTING lane's policy (provisioning brings food to
; the kitchen; nothing here presupposes food).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The go sub-goal INHERITS the bring goal's drive through /caused_by (worship_go
; shape) - the MINTING lane owns the utility (provisioning: provision_rearm 90).
; <dest> may be a premises BUILDING or a ROOM (provisioning aims the kitchen); the
; generic go task (go.hs) reaches either - enter the structure, walk into the room.
(npc-think bring_go
  (goal {@self bring ?ware ?dest})
  (when (not (at_location @self ?dest)))
  (effects (maintain-proposal {@self go ?dest})))

; AT the destination: PROPOSE the put-down act (goals never propose themselves). No (utility):
; the proposal inherits the minting lane's drive up the /caused_by chain (like bring_go).
(npc-think bring_at_dest
  (goal {@self bring ?ware ?dest})
  (when (at_location @self ?dest))
  (effects (maintain-proposal {@self bring ?ware ?dest})))