; ----------------------------------------------------------------------------
; close_business_errand (act lane) - the npc-ACT half of the business-failure split.
; The go/dwell think rungs live in npc-think/close_business_errand.hs.
;
; The decision (npc-think/close_business.hs) minted {@self goal {@self
; close_business <own_articles>}} on the proprietor each December. The intra-day
; think rungs drain it: the owner goes to his OWN premises and winds the firm up in
; person - so the failure happens AT the workplace, by the man himself, leaving the
; co-presence a witness (and his staff) would see, instead of a faceless town-lane
; cull. His articles are the goal focus, so the premises are (articles-building
; (goal-focus close_business)) - mirrors apprentice_errand.
;
;   close_business_act : the promoted act - the winding-up, entirely over the owner's
;                  OWN state (no cross-mind write), then ends the act + the goal.
;
; THE TEARDOWN - NO TELEPATHY. The owner touches ONLY his own state + true env
; primitives. He does NOT reach into any worker's mind (the old (dissolve-org)
; op did, ending every roster worker's employment beliefs cross-mind - BANNED):
;   1. He SHUTTERS the premises building - (shutter-building ?wp) sets a
;      perceivable `closed` env attr (macros/closure_macros.hs). Each worker
;      reconciles his own stale {@self employer}/{@self job} beliefs when he next
;      turns up and reads the shut doors (events/npc-think/reconcile_closed.hs) -
;      perception at co-presence, never a mind edit. The building is MARKED, not
;      destroyed, so workers can still perceive the closed state.
;   2. He DESTROYS his OWN incorporation documents - the articles (?art, the goal
;      focus) and its register (?reg, read off the articles' register slot). These
;      are single, known entities he holds, destroyed at his OWN act-completion -
;      not a role-enumeration sweep - so the destroys are safe (buy_home_act
;      destroys a single bound listing the same way). The articles' fields are read
;      BEFORE the destroy; end-act / end-goal match by label, independent of the
;      now-gone documents.
;   3. He LISTS his OWN premises for sale IF he owns it - gated on his own {@self
;      own ?wp} belief (register_ownership mints it for pooled premises; a
;      home-seated firm's `premises` is a room in his own home, which he does NOT
;      hold an {own} belief on, so he does not list his dwelling; a leased premises
;      he simply vacates, and the landlord perceives the vacancy later). The listing
;      is his own act on his own property: create a for_sale_listing document in the
;      premises + write its [building] record + mint his own {?wp availability
;      for_sale} belief - the same abs-native listing list_to_let_act files for a
;      let, NOT the banned cross-mind list_for_sale op.
; ----------------------------------------------------------------------------

; The winding-up - the owner's own act on his own state. Binds his articles to a
; plain ?var, reads the premises + register off it, shutters the doors, destroys
; his own documents, lists the premises for sale if he owns it, and clears the act
; + goal on completion. No cross-mind write: workers reconcile themselves via
; reconcile_closed when they find the premises shut.
(npc-act close_business_act
  (bind (goal-focus close_business) ?art)
  (when (believes {@self close_business}))
  (duration 90)
  (act-effects
    ; his own articles carry the premises building + the register document.
    (read-doc-record [k articles_of_incorporation] ?art (building ?wp) (register ?reg))
    ; 1. shutter the doors - a perceivable `closed` fact; staff reconcile by seeing it.
    (shutter-building ?wp)
    ; 3. list the premises for sale IF he owns it (a leased / home-seated premises has
    ;    no {@self own ?wp} belief, so he does not list it - he just vacates / keeps home).
    (if (believes {@self own ?wp})
        (do
          (create-entity [k for_sale_listing] (qual location ?wp) (bind ?listing))
          (write-doc-record [k for_sale_listing] ?listing (building ?wp))
          (begin-belief {?wp availability [k for_sale]})))
    ; 2. destroy his OWN incorporation documents (single bound entities at completion).
    (destroy-entity ?reg)
    (destroy-entity ?art)
    ; 4. clear the act + the goal (match by label, independent of the gone documents).
    (end-act {@self close_business})
    (end-goal {@self close_business})))
