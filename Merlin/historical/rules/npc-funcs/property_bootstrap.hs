; ----------------------------------------------------------------------------
; property_bootstrap.hs - the world-gen property seed, authored as a MINDLESS
; (define-func) the engine invokes ONCE at bootstrap (call_hs_func, no actor -
; runs in the abs mind; @self would resolve to @fail, so this func never uses it).
;
; Files one title_deed per building, owner @nothing (vacant) - the land-registry
; record every ownership query reads. A founder claims a vacant deed (found-org-seq
; direct-claim); a buyer's RECORD_SALE updates the owner. Replaces the C++
; hsim_bootstrap property seed (register_ownership + the listing stacks).
; ----------------------------------------------------------------------------

(define-func seed_property ()
  (for-each ?b (env-entities [k building])
    (spatial ?b room): ?room
    (if ?room
      (then
        (create-entity [k title_deed] (qual location ?room)): ?deed
        (table-init ?deed building owner)
        (table-add ?deed building ?b)))))
