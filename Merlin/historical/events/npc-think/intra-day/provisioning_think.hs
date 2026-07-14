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
  (short-term-think)
  (role @self (grown @self)
              (believes {@self job [k job cook]})
              (not (believes {@self household_cook ?})))
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (pub-bb-none ?home cook)))
  (cont-fire-effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think claim_cook_woman
  (short-term-think)
  (role @self (grown @self)
              (believes {@self gender [k female]})
              (not (believes {@self household_cook ?}))
              (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (pub-bb-none ?home cook)
             (not (and (bind {@self mother ?mum})
                       (believes {?mum home ?home})))))
  (cont-fire-effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think claim_cook_man
  (short-term-think)
  (role @self (grown @self)
              (believes {@self gender [k male]})
              (not (believes {@self household_cook ?}))
              (not (believes {@self spouse ?}))
              (not (believes {@self class_situation [k upper]})))
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (pub-bb-none ?home cook)
             (not (and (bind {@self child ?c})
                       (believes {?c gender [k female]})
                       (believes {?c home ?home})))))
  (cont-fire-effects
    (pub-bb-post ?home cook (cook_marker_ttl_cycles))
    (begin-belief {@self household_cook ?home})))

(npc-think renew_cook
  (short-term-think)
  (role ?home (believes {@self household_cook ?home}))
  (cont-fire-effects (pub-bb-post ?home cook (cook_marker_ttl_cycles))))

; ---- the pressure: the kitchen larder is low --------------------------------

(npc-think want_provisions
  (short-term-think)
  (role ?home (believes {@self household_cook ?home}))
  ; The kitchen resolves from the cook's OWN room knowledge (the home pre-teach
  ; mints {home room <r>}): the kind-cast bind picks the is-a kitchen target.
  (when (and (not (under-attack))
             (bind {?home room [k kitchen]:?kitchen})
             (< (count-believed-located [k food] ?kitchen) (larder_low_water))))
  (utility 77)
  (cont-fire-effects
    (excl-goal {@self provision})))

; ---- the errand: go to THE provisions shop (never a generic one) ------------
; The go sub-goal INHERITS the provision goal's drive through /cause (the
; worship_go shape - no own utility); at the shop the go retires, the standing
; goal is the leaf, and provision_act promotes on its when.

(npc-think provision_go
  (short-term-think)
  (goal {@self provision})
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (is-entity ?shop)
             (not (in-building ?shop))))
  (cont-fire-effects (go-into ?shop)))

(npc-think provision_orient
  (short-term-think)
  (goal {@self provision})
  (bind (target {@self provisions_shop ?}) ?shop)
  (when (and (not (under-attack))
             (not (is-entity ?shop))
             (no-goal {@self orient})))
  (cont-fire-effects
    (begin-goal {@self orient})))

; ---- the delivery drive ------------------------------------------------------
; Laden with food = the standing pressure to deliver it, re-stamped per
; deliberation (so the intention survives the window gap). ONE desire owns the
; bring goal's whole utility: 90 on the road (outbids the 77 provision pull the
; moment the basket is in hand; bring_go inherits it via /cause), MAXIMUM once
; standing at the kitchen - the put-down takes a minute and nobody beds down
; still holding the shopping.

(npc-think provision_rearm
  (short-term-think)
  (role ?home (believes {@self home ?home}))
  (when (and (not (under-attack))
             (bind {?home room [k kitchen]:?kitchen})
             (control [k food])))
  (utility (if (at-place ?kitchen) 250 90))
  (cont-fire-effects (begin-goal {@self bring [k food] ?kitchen})))
