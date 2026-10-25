; ----------------------------------------------------------------------------
; depart - the emigrant's OWN act of packing up and leaving the parish. Matched by
; the standing {@self DEPART} goal that emigration.mc (the decision) mints. The
; emigrant acts on THEMSELVES, their OWN beliefs, and PUBLIC documents keyed on his
; OWN identity only - no scan, no mark, no sweep, and NO cross-mind write. Every
; step below is the atomic-op decomposition of the old (fire ...) / release-home
; teardown, none of which reach into another NPC's mind:
;
;   QUIT HIS POST - he ends his OWN job belief ({@self job ?job}; its org / salary /
;       level decorations go with it) and scrubs his OWN row off the firm's employee-register
;       (a public doc), keyed on (find worker @self). Reaching the register is a
;       pure forward belief walk he already holds: {@self job.org ?org} ->
;       {?org record ?art} (the founder always holds `record`; an oriented worker
;       acquires it at orient_errand) -> the articles' `register` field. If he never
;       oriented and holds no `record`, the row is LEFT stale: every register reader
;       (materialize_employment, hold-meet) already guards dead/emigrated rows with
;       (alive ?m), and the row lapses by decay. He never edits the org's mind.
;
;   RELEASE HIS HOME - self-belief + document primitives, split by tenure:
;     OWNED ({@self own ?home}): he lists it for sale by inlining the true doc
;       primitives (a public for-sale-listing document, [building] slot - the same
;       channel buy_home_action's read-public-register consumes), then drops his own
;       {@self own}/{@self home}. The title-deed is LEFT naming him: a buyer's
;       buy_home_action rewrites the deed and skips the now-gone seller's {own} via its
;       own (alive ?seller) guard, exactly as execute_purchase handled an emigrated
;       seller - so voiding the deed here would only strip the property of any
;       ownership record.
;     LEASED / occupied (no {own}): he simply vacates, dropping his OWN
;       {?home tenant @self} + {@self home}. The landlord is NOT touched - he learns
;       the dwelling is empty by perception (co-presence) or the belief lapses by
;       decay, and his re-letting chain (list-to-let.mc) surfaces the vacancy with no
;       scan. The lessor's tenancy belief is HIS to reconcile, never the emigrant's.
;
;   (end-belief @self spouse) - the survivor's marriage reference to someone who has
;       gone is dropped (was ended at decision time before the split).
;   (set-outcome {..} /succ)              - close the act-belief (the goal's teardown is its minter's).
;   (destroy-entity @self) - the emigrant leaves the world (no corpse, no burial).
;
; THE SELF-DESTROY: destroying an entity deletes its mind, and this act runs in that mind,
; so (destroy-entity @self) concludes his acts and takes him off the living count at once
; but removes the body only once the act has returned (t_rule_runtime::queue_self_destroy),
; before the instant's wake pass - he never deliberates again.
;
; NOTE - the emigrant removes only HIMSELF. A departing business OWNER leaves a
; headless org (its articles / register persist minus his row); winding the firm up
; is close_business.mc's job, not depart's.
; ----------------------------------------------------------------------------

; The packing day: he settles his affairs and leaves - his posts, his home, his marriage,
; then the world.
(action {@self DEPART}:?DEPART
  (motor body legs)
  (duration (seconds 480 min))                     ; ~a day spent packing up and settling affairs
  (effects
    (set-outcome ?DEPART /succ)
    (destroy-entity @self)))
