; ----------------------------------------------------------------------------
; errand_macros.hs - the shared "route to a venue, then act there" skeleton, and
; the shared "read a public register, mint beliefs" reader.
;
; These collapse the go/dwell/act duplication that worship_go / orient_go /
; club join_go (and their dwell twins) copy-paste, and the read-the-register loop
; orient_act runs, into ONE reusable definition each. Both are CONTENT-FREE: the
; goal label, the venue var, the listing kind, and the minted belief label are all
; the caller's arguments.
;
; Macros expand in-place, so these are used INSIDE an event's (effects ...) /
; (act-effects ...) block. The VENUE ROLE itself is still cast inline in the
; event (a role clause cannot be macro-generated), filtered to the venue kind and
; scored by proximity - the macros take the resulting KNOWN ?venue var (never a
; world scan; knowledge-honest by construction).
; ----------------------------------------------------------------------------

; (route-to-venue-then-act ...) and (go-into ...) - the old STAGE-5 two-arm routing
; macros - are RETIRED. Errand routing now mints {@self enter ?venue} into the generic
; enter chain (events/npc-think/intra-day/enter.hs), which front-parks the structure's
; threshold then steps into its entrance room, reactive on the actor's own movement
; (§5.10/§5.11). The per-trip `approached` bb-flag is gone (whereabouts is the at-threshold
; spatial gate, not a flag).

; (read-public-register ?kind ?label): the register-reading loop. For every live
; document of ?kind in the public register, read its `building` field (slot 0 -
; the shared listing/deed contract in core_documents.hs) and mint {@self <label>
; ?b}. A public-register read in an ACT effect (not a role filter), so it stays off
; the per-candidate object cache; the minted beliefs are mental writes, safe inside
; the document walk (no entity create / destroy). Housing / landlord / sports
; roster reads reuse this with their own listing kind + belief label.
;
;   (read-public-register [k for_sale_listing] for_sale)   ; mint {@self for_sale ?b}
(define-macro read-public-register (?kind ?label)
  (for-each ?rec (documents ?kind)
    (do
      (read-doc-record ?kind ?rec (spatial ?b building))
      (begin-belief {@self ?label ?b}))))
