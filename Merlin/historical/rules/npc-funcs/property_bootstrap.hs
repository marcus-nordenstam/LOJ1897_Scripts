; ----------------------------------------------------------------------------
; property_bootstrap.hs - the world-gen property seed, authored as a MINDLESS
; (define-func) the engine invokes ONCE at bootstrap (call_hs_func, no actor -
; runs in the abs mind; @self would resolve to @fail, so this func never uses it).
;
; (1) Files one title_deed per building, owner @nothing (vacant) - the land-registry
;     record every ownership query reads. A founder claims a vacant deed (found-org-seq
;     direct-claim); a buyer's RECORD_SALE updates the owner.
; (2) Builds the singleton for_sale_listings REGISTER (a table-doc, one [building deed]
;     row per vacant building) the house-agency holds. Premises-seekers SCAN THIS TABLE
;     (for-each-row / table-match) instead of the whole deed registry: a founder reads it
;     for a building of the kind he needs, claims it (table-set the deed's owner + drop the
;     row), and founds on it; a homebuyer reads it for a dwelling. The row carries the deed
;     so a claim needs no deed re-scan. A claim / RECORD_SALE drops the building's row.
; Replaces the C++ hsim_bootstrap property seed (register_ownership + the listing stacks).
; ----------------------------------------------------------------------------

(define-func seed_property ()
  ; The singleton for-sale register, created once in the first building's room.
  (for-each ?b0 (env-entities [k building])
    (spatial ?b0 room): ?r0
    (if (and ?r0 (none (env-entities [k for_sale_listings])))
      (then
        (create-entity [k for_sale_listings] (qual location ?r0)): ?reg0
        (table-init ?reg0 building deed)
        (break))))
  ; A vacant deed per building; list every one (all vacant at seed) in the register.
  (for-each ?b (env-entities [k building])
    (spatial ?b room): ?room
    (if ?room
      (then
        (create-entity [k title_deed] (qual location ?room)): ?deed
        (table-init ?deed building owner)
        (table-add ?deed building ?b)
        (for-each ?reg (env-entities [k for_sale_listings])
          (table-add ?reg building ?b deed ?deed))))))
