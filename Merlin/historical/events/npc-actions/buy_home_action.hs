; ----------------------------------------------------------------------------
; buy_home_action - the npc-ACT half of the purchase demand (buy_home.hs).
;
; Two acts, both promoted at a house agent's office:
;
;   read_listings_action : the KNOWLEDGE CHANNEL. Reads the PUBLIC for-sale register
;     (read-public-register, the foundation macro) so @self forms {@self for_sale
;     ?b} beliefs for every listing on file - this is how he LEARNS what is for
;     sale (no scan). choose_home (buy_home.hs) then casts over these beliefs.
;
;   buy_home_action : the sale, from the BUYER's side only (no cross-mind writes). It
;     re-validates that ?dwell's for_sale_listing still exists (a stale / already-
;     bought dwelling yields nothing - the walk finds no match), then:
;       - rewrites the registry title_deed to name @self (update-doc-record) - the
;         AUTHORITATIVE transfer of record, which overrides the seller's now-stale
;         {own} belief for every future reader of the deed;
;       - mints @self's {own} + {home} (@excl, so it replaces the natal home) +
;         the {?dwell occupant @self} occupancy record;
;       - drops his own read-in for_sale belief and destroys the listing document.
;     @self NEVER touches the seller's mind. The seller's {own} belief is left to
;     decay as a harmless memory the deed authoritatively supersedes (most for-sale
;     supply is from dead / emigrated owners who hold no mind at all).
;     The listing destroy is a SINGLE bound doc at completion, immediately followed
;     by (break), so the live documents walk is not corrupted by the removal.
; ----------------------------------------------------------------------------

(npc-action {@self read_listings}
  (duration 30)
  (effects
    (read-public-register [k for_sale_listing] for_sale)
    (set-outcome {@self read_listings} succ)))

(npc-action {@self buy_home ?dwell}
  (duration 60)
  (effects
    ; Re-validate: ?dwell must still be on the for-sale register.
    (for-each ?listing (documents [k for_sale_listing])
      (do
        (read-doc-record [k for_sale_listing] ?listing (building ?lb))
        (if (= ?lb ?dwell)
            (then
              ; Rewrite the deed to name @self - the authoritative record transfer.
              (for-each ?deed (documents [k title_deed])
                (do
                  (read-doc-record [k title_deed] ?deed (building ?db))
                  (if (= ?db ?dwell)
                      (then
                        (update-doc-record [k title_deed] ?deed (owner @self))
                        (break)))))
              ; @self takes ownership, moves in (home is @excl - leaves the natal
              ; home), and is recorded as the dwelling's occupant.
              (begin-belief {@self own ?dwell})
              (begin-belief {@self home ?dwell})
              (begin-belief {?dwell occupant @self})
              (end-belief @self for_sale ?dwell)
              (destroy-entity ?listing)
              (break)))))
    (set-outcome {@self buy_home ?dwell} succ)))
