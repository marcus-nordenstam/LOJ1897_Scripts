; ----------------------------------------------------------------------------
; depart - the emigrant's OWN act of packing up and leaving the parish. Matched by
; the standing {@self depart} goal that emigration.hs (the decision) mints. The
; emigrant acts on THEMSELVES, their OWN beliefs, and PUBLIC documents keyed on his
; OWN identity only - no scan, no mark, no sweep, and NO cross-mind write. Every
; step below is the atomic-op decomposition of the old (fire ...) / release-home
; teardown, none of which reach into another NPC's mind:
;
;   QUIT HIS POST - he ends his OWN employment beliefs ({@self employer ?org},
;       {@self job ?job}) and scrubs his OWN row off the firm's employee_register
;       (a public doc), keyed on (find worker @self). Reaching the register is a
;       pure forward belief walk he already holds: {@self employer ?org} ->
;       {?org record ?art} (the founder always holds `record`; an oriented worker
;       acquires it at orient_errand) -> the articles' `register` field. If he never
;       oriented and holds no `record`, the row is LEFT stale: every register reader
;       (materialize_employment, hold_meet) already guards dead/emigrated rows with
;       (alive ?m), and the row lapses by decay. He never edits the org's mind.
;
;   RELEASE HIS HOME - self-belief + document primitives, split by tenure:
;     OWNED ({@self own ?home}): he lists it for sale by inlining the true doc
;       primitives (a public for_sale_listing document, [building] slot - the same
;       channel buy_home_act's read-public-register consumes), then drops his own
;       {@self own}/{@self home}. The title_deed is LEFT naming him: a buyer's
;       buy_home_act rewrites the deed and skips the now-gone seller's {own} via its
;       own (alive ?seller) guard, exactly as execute_purchase handled an emigrated
;       seller - so voiding the deed here would only strip the property of any
;       ownership record.
;     LEASED / occupied (no {own}): he simply vacates, dropping his OWN
;       {?home tenant @self} + {@self home}. The landlord is NOT touched - he learns
;       the dwelling is empty by perception (co-presence) or the belief lapses by
;       decay, and his re-letting lane (list_to_let.hs) surfaces the vacancy with no
;       scan. The lessor's tenancy belief is HIS to reconcile, never the emigrant's.
;
;   (end-belief @self spouse) - the survivor's marriage reference to someone who has
;       gone is dropped (was ended at decision time before the split).
;   (end-goal / end-act)   - close the standing goal + the act-belief.
;   (destroy-entity @self) - the emigrant leaves the world (no corpse, no burial).
;
; SAFE self-destroy - VERIFIED against the completion path (hse_engine.cc
; run_window_stepper): destroy-entity is the LAST effect, so every prior effect
; touches a LIVE mind. mx_destroy_entity -> destroy_mind resets @self's _mind_id to
; k_abs_mind_id, so mx_is_alive(@self) is false immediately after. The completion
; loop's post-body perceive_here (guarded by mx_is_alive) and seed_venue_acquaintance
; (guarded on a live location, which destroy clears) both no-op, and any queued
; completion for @self is skipped by the mx_is_alive guard. Because the completion
; heap is popped one actor at a time (NOT an in-flight mx_for_each_entity role walk),
; destroying @self here does not corrupt any iteration - unlike a role-enumerated
; event, which still must never destroy.
;
; NOTE - the emigrant removes only HIMSELF. A departing business OWNER leaves a
; headless org (its articles / register persist minus his row); winding the firm up
; is close_business.hs's job, not depart's.
; ----------------------------------------------------------------------------

(npc-act depart_act
  (when (believes {@self depart}))
  (duration 480)                     ; ~a day spent packing up and settling affairs
  (act-effects
    ; --- quit his post: end his OWN employment beliefs; scrub his OWN roster row --
    ; STANDALONE value-binds (scope forward through the effects, unlike a bind INSIDE an
    ; (if ...) condition, which does not reach the branch); is-entity guards stand in for
    ; the "does he hold this belief" gate.
    (bind (target {@self employer}) ?org)
    (if (is-entity ?org)
      (do
        (bind (target {?org record}) ?art)
        (if (is-entity ?art)
          (do
            (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
            (remove-doc-record [k employee_register] ?reg (find worker @self))))
        (end-belief {@self employer ?org})
        (bind (target {@self job}) ?job)
        (if (is-entity ?job) (end-belief {@self job ?job}))))

    ; --- release his home: OWN -> list for sale; LEASE -> vacate (self-beliefs only)
    (bind (target {@self home}) ?home)
    (if (is-entity ?home)
      (if (believes {@self own ?home})
        (do
          (create-entity [k for_sale_listing] (qual location ?home) (bind ?listing))
          (write-doc-record [k for_sale_listing] ?listing (building ?home))
          (end-belief {@self own ?home})
          (end-belief {@self home ?home}))
        (do
          (if (believes {?home tenant @self}) (end-belief {?home tenant @self}))
          (end-belief {@self home ?home}))))

    (end-belief @self spouse)
    (end-goal {@self depart})
    (end-act {@self depart})
    (destroy-entity @self)))
