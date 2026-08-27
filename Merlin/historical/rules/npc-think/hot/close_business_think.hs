; ----------------------------------------------------------------------------
; close_business - the per-owner business-FAILURE decision.
;
; The flat annual 2% market cull becomes per-proprietor pressure: each December a
; business owner weighs his OWN standing (means + merit) against the town's
; economic weather and may resolve to wind the firm up. A struggling man (low
; wealth, slack diligence) in a downturn or panic folds far more readily than a
; wealthy, diligent one in an expansion - so failures cluster on the weak in bad
; years, instead of striking uniformly at random.
;
; ACTOR = the proprietor, identified from his OWN beliefs, NO world scan. ?org is
; a CACHED role (both filters test the SAME candidate):
;   {@self job.org [k org business]:?org} - he is seated at ?org AND ?org is-a
;                            trading firm, so churches / clubs / hospitals (public
;                            orgs, never "fail" this way) are excluded. The
;                            kind-cast matches the org OBJECT's permanent kind -
;                            never the decaying {?org isa ...} belief, which
;                            lapses at ~9 months and would darken the gate for
;                            any firm older than that. AND
;   {?org founder @self}   - the OWNER test. `founder`'s target is the REAL founder,
;                            so this holds ONLY for him. (record alone is NOT
;                            owner-exclusive: orient_errand mints {?org record ?art}
;                            for ANY worker who reads the articles at church - so a
;                            mere employee would falsely pass a record-only gate.)
; The articles read (any {?org record ?}).target: ?art stays in (when ...) - a
; role filter cannot bind, and the suffix bind provably threads to the lifecycle
; block (same eval env; the retire / sack routing thinks rely on it).
;
; LANE: a yearly timer ((cooldown 1 y)) runs the failure roll once a year and
; mints the LATCHED winding-up goal. The derived means / merit dims are (target ...)
; reads, cached annually by derive_prototypes - the same reads the founding rules use.
;
; The routing (go / dwell) and the winding-up ACT live in the mirror errand file
; npc-act/close_business_errand.hs.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; TERMINAL (act_body_purification): AT his own premises, PROPOSE the winding-up. close_business is
; a proposed label, so the bare {@self CLOSE_BUSINESS} goal does not promote on its own - the act
; runs ONLY here, ONLY once the owner has reached the premises (at-workplace). articles-building
; binds ?wp (the firm's premises) off ?art, the focus bound off the {@self CLOSE_BUSINESS} goal - the same read the close_go routing rung uses
; (npc-think/close_business_errand.hs), whose (not (spatial @self building ?wp)) gate this arrived condition
; negates. The (goal ...) gate supplies the /caused_by.
(npc-think close_at_premises
  (goal {@self CLOSE_BUSINESS ?art})
  (when (and (articles-building ?art ?wp)
             (spatial @self building ?wp)))
  (effects (maintain-proposal {@self CLOSE_BUSINESS ?art ?wp})))

; Outcome twin of the winding-up: he LISTS his OWN premises for sale IF he owns
; it (a leased / home-seated premises has no {@self own ?wp} belief - he just
; vacates). The availability belief is the fired-once latch.
(npc-think list_failed_premises
  (role @self {@self CLOSE_BUSINESS ? ?wp /succ}
              {@self own ?wp}
              (not {?wp availability ?}))
  (effects
    (create-entity [k for_sale_listing] (qual location ?wp)): ?listing
    (set-writing ?listing (written-msg {?wp availability [k for_sale]}))
    (set-attr ?listing address ?wp)
    (for-each ?stk (documents [k for_sale_listing_stack]) (do (push ?listing ?stk) (break)))
    (begin-belief {?wp availability [k for_sale]})))
