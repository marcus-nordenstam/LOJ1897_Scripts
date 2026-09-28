; ----------------------------------------------------------------------------
; collection_macros - the fungible-item PILE vocabulary (see Objects.mon `pile`
; + things.mon (pile)). A pile is ONE self-contained entity standing for N identical
; items: it stores the item KIND (content-kind attr) and a COUNT, never per-item
; entities. A co-present observer mints exactly {pile content-kind [k <kind>]} +
; {pile count N} regardless of N - the memory-compression payoff.
;
; The count is the source of truth; increment/decrement is a single set-attr
; (one perception rule, not N). Extraction spawns a real item OUT of the pile
; (dec + create-entity) and is necessarily content-SPECIFIC because create-entity
; takes only a syntactic [k <kind>] - so the extract site names the kind
; literally; the find/ensure/count/mutate ops below are kind-generic.
; ----------------------------------------------------------------------------




