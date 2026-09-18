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
; Macros expand in-place, so these are used INSIDE a rule's (effects ...) /
; (act-effects ...) block. The VENUE ROLE itself is still cast inline in the
; rule (a role clause cannot be macro-generated), filtered to the venue kind and
; scored by proximity - the macros take the resulting KNOWN ?venue var (never a
; world scan; knowledge-honest by construction).
; ----------------------------------------------------------------------------

; (route-to-venue-then-act ...) and (go-into ...) - the old STAGE-5 two-arm routing
; macros - are RETIRED. Errand routing now mints {@self enter ?venue} into the generic
; enter chain (rules/npc-think/intra-day/enter.hs), which front-parks the structure's
; threshold then steps into its entrance room, reactive on the actor's own movement
; (§5.10/§5.11). The per-trip `approached` bb-flag is gone (whereabouts is the at-threshold
; spatial gate, not a flag).

; Public-register READING is no longer a global scan + slot pull. A register is a
; physical stack of documents lodged at its venue; a reader walks there and BROWSES
; it, adopting each document's writing as beliefs - see rules/npc-tasks/read-listings-task.hs
; and the buy_home_read driver (buy_home_think.hs).
