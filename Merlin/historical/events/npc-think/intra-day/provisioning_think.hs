; ----------------------------------------------------------------------------
; provisioning (npc-think lane) - keeping the household LARDER stocked. The
; larder is THE KITCHEN (every inhabited home has one - world-gen aborts
; otherwise), and ONE cook per household owns the errand.
;
; THE COOK: any grown resident may claim the role; the home's PUBLIC bb `cook`
; marker is the synchronization (the buy_home `claimed` pattern) - the first
; claimant posts it, every later would-be claimant sees it and defers. The
; sitting cook re-posts the marker each cycle, so the ttl only clears a DEAD
; (or emigrated) cook and the household re-elects.
;
; THE ERRAND (the worship/drink shape - a pressure, a go, a do-at-the-place):
;   want_provisions : cook + the believed kitchen larder is low -> the standing
;                     {@self provision} goal (the pressure).
;   provision_go    : knows the provisions shop -> travel there. Provisioning
;                     NEVER wanders generic shops: the ONLY venue is the shop
;                     the cook KNOWS sells provisions ({@self provisions_shop}).
;   provision_orient: knows NO provisions shop -> read the public register of
;                     incorporations at the church (the orient errand), which
;                     teaches where the grocer trades.
;   provision_act   : AT the known shop the standing goal is the leaf and
;                     (npc-act/provision_act.hs) promotes on its own when: buy a
;                     basket and mint {@self bring [k food] <kitchen>} - the
;                     general bring lane carries it home and puts it down IN the
;                     kitchen.
;   provision_rearm : laden with food = the standing pressure to deliver it, so
;                     re-mint the bring goal each deliberation; a full hand is a
;                     live pressure re-read every cycle, so the basket can never
;                     fossilize in hand across the window gap.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/possession_macros.hs")
(include "../../../macros/tunables.hs")

; ---- the cook election (public-bb synchronized, one per household) ----------
; Priority ladder: hired cook > wife > (oldest) daughter > husband/father >
; bachelor alone. Encoded as per-mind defer-gates, ties within a tier resolved
; first-come by the bb marker:
;   hired  - holds the cook job; claims outright.
;   woman  - any grown woman of the house, UNLESS her living mother shares the
;            home (the senior woman outranks her: wife > daughter in one gate)
;            or she is upper-class (her household hires its cook).
;   man    - only with no living spouse (his wife owns the kitchen) and no
;            believed daughter under his roof; covers widower and bachelor.
; Known approximations: "oldest" daughter is first-come among sisters, and a
; late-hired cook does not usurp a sitting family cook (first claim sticks).

(npc-think claim_cook_hired
  (schedule always)
  (role @self (grown @self)
                           (believes {@self job [k job cook]})
              (not (believes {@self household_cook ?})))
  (role ?home (believes {@self home ?home}))
  (when (pub-bb-none ?home cook))
  (effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think claim_cook_woman
  (schedule always)
  (role @self (grown @self)
                           (believes {@self gender [k female]})
              (not (believes {@self household_cook ?}))
              (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home}))
  (when (and (pub-bb-none ?home cook)
             (not (and (bind {@self mother ?mum})
                       (believes {?mum home ?home})))))
  (effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think claim_cook_man
  (schedule always)
  (role @self (grown @self)
                           (believes {@self gender [k male]})
              (not (believes {@self household_cook ?}))
              (not (believes {@self spouse ?}))
              (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home}))
  (when (and (pub-bb-none ?home cook)
             (not (and (bind {@self child ?c})
                       (believes {?c gender [k female]})
                       (believes {?c home ?home})))))
  (effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think renew_cook
  (schedule always)
  (role ?home (believes {@self household_cook ?home}))
  (effects (pub-bb-post ?home cook (cook_marker_ttl_cycles))))

; ---- the pressure: the kitchen larder is low --------------------------------

(npc-think want_provisions
  (schedule always)
  (role ?home (believes {@self household_cook ?home}))
  ; The kitchen resolves from the cook's OWN room knowledge (the home pre-teach
  ; mints {home room <r>}): the kind-cast bind picks the is-a kitchen target.
  (when (and (bind {?home room [k kitchen]:?kitchen})
             (< (count-believed-located [k food] ?kitchen) (larder_low_water))))
  (utility 77)
  (effects       (begin-goal {@self provision}))
  (cease-effects (end-goal   {@self provision})))

; TERMINAL step (act_body_purification): the buy is PROPOSED, guarded by being at a shop - the
; same at-place-kind precondition provision_act's (when) used to carry (identity is enforced by
; the routing: provision_go walks only to the KNOWN provisions shop). Because `provision` is a
; proposed label, auto_propose skips the {@self provision} goal (it still persists + drives
; provision_go/orient), so the buy promotes ONLY here, ONLY at a shop - closing the off-shop
; spurious-promotion hole a bare pure act would open. Reactive re-propose each cycle at the shop.
(npc-think provision_at_shop
  (schedule on-commit)
  (if-blocked hold)
  (goal    {@self provision})
  (when    (at-place-kind [k building shop]))
  (utility 77)
  (effects (maintain-proposal {@self provision})))

; ---- the errand: go to THE provisions shop (never a generic one) ------------
; The go sub-goal INHERITS the provision goal's drive through /cause (the
; worship_go shape - no own utility); at the shop the go retires, the standing
; goal is the leaf, and provision_act promotes on its when.

(npc-think provision_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self provision})
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (is-entity ?shop)
             (not (in-building ?shop))))
  (effects       (begin-goal {@self enter ?shop}))
  (cease-effects (end-goal   {@self enter ?shop})))

; MAINTENANCE co-minter of the shared {@self orient} search: while the provisioner knows no
; provisions shop, mint the orient goal; cease the moment orient_act learns one ({@self
; provisions_shop}). No (no-goal) dedup - under multi-rule support each lane co-mints its own
; source on {@self orient} and withdraws it independently; the goal lives until the last withdraws.
(npc-think provision_orient
  (schedule on-commit)
  (goal {@self provision})
  (when (not (believes {@self provisions_shop ?})))
  (effects       (begin-goal {@self orient}))
  (cease-effects (end-goal   {@self orient})))

; ---- the delivery drive ------------------------------------------------------
; Laden with food = the standing pressure to deliver it, re-stamped per
; deliberation (so the intention survives the window gap). ONE desire owns the
; bring goal's whole utility: 90 on the road (outbids the 77 provision pull the
; moment the basket is in hand; bring_go inherits it via /cause), MAXIMUM once
; standing at the kitchen - the put-down takes a minute and nobody beds down
; still holding the shopping.

(npc-think provision_rearm
  (schedule always)
  (role ?home (believes {@self home ?home}))
  (when (and (bind {?home room [k kitchen]:?kitchen})
             (control [k food])))
  (utility (if (at-place ?kitchen) (then 250) (else 90)))
  (effects       (begin-goal {@self bring [k food] ?kitchen}))
  (cease-effects (end-goal   {@self bring [k food] ?kitchen})))
