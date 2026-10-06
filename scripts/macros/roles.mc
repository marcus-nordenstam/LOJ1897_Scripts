; ----------------------------------------------------------------------------
; Shared role-filter macros for hsim rules (formerly (define-role ...) templates).
;
; Each is a (define-macro ...) taking the candidate ?x - or @self at a gate. Drop it
; into a (role ...) as a single filter:
;     (role ?b   {?b isa [k human], condition [k alive]}   <extra-filters>...)   ; BIND + enumerate ?b
;     (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]})                        ; GATE the deliberating NPC
; The candidate is passed explicitly (no ?this rewrite): whatever token you pass is
; the subject the body's patterns read.
;
; Multi-criterion predicates bundle with (and ...) plus the believes comma-sugar
; ({?x a, b, c} = a AND b AND c on the shared subject ?x, written once). Every filter
; is a belief-query - kind / liveness / gender / age read from PERCEIVED beliefs (the
; attrs carry (auto-percept) in attrs.mon, so a mind internalizes {?o isa <kind>} /
; {?o condition alive} / {?o gender <g>} / {?o age-band <band>} on sight, even for
; strangers; the self mirrors them about @self via update_self_awareness). No
; omniscient (kind ...) / (alive) / (attr ...) ops. Another's age is band-only
; (see macros/age_macros.mc); his own is {@self age <years>}.
;
; A BINDING role (?x) reads the deliberating mind's OWN beliefs ABOUT the candidate
; ({?x <label> ..}) - what the per-(mind, signature) object cache materializes; an
; @self GATE reads its beliefs about itself. (No 2-arg {?x {@self ..}} cross-mind
; reads - those are telepathy and are not object-cacheable.) The light @self gates
; carry no isa/condition (the deliberating NPC is a living human by construction) -
; just the age band.
;
; All filters of one role are membership-tested against the SAME candidate, so a
; multi-filter role is a shared-witness join ({@self home ?h} + {@self own ?h} =
; "owns the home he lives in"). A kind-cast target [k K]:?x (ONE kind, no alts) is
; identity AND is-a against the object's PERMANENT kind - the decay-proof kind test
; on a relation ({@self employer [k business]:?org}); chain labels (a.b) and
; options compose as filters too. A filter with a FREE target var
; ({?cand record ?art}) is a cached EXISTENCE criterion that BINDS the var at
; fire time off the drawn candidate - producing binds role-ify too; only
; non-belief ops, dynamic-label binds and act-desire gates stay in (when).
; ----------------------------------------------------------------------------






