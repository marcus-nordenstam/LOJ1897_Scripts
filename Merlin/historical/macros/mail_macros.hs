; ----------------------------------------------------------------------------
; mail_macros.hs - letter delivery + the mail-room resolver, as define-macros.
;
; These replace the C++ mail-delivery content (spawn-letter / mail-space ops and
; the read_pending_mail window pass). Delivery is now composed in .hs from the
; atomic, content-free ops (create-entity / set-writing / set-attr / file-in-stack /
; room-of); the room-kind preference lives HERE, not baked into the engine.
;
; SPATIAL MODEL: `home` targets the BUILDING directly (place_macros.hs); a premises'
; mail pile lives in its mail room (hallway preferred, else living_room, else kitchen).
; The pile is created + sized on demand by the stack-filing seam (push-driven geometry).
; ----------------------------------------------------------------------------

; (mail-space ?premises): the mail room of ?premises where its mail pile lives -
; the first present of hallway / living_room / kitchen (else the premises' first
; room, else the premises itself). The .hs-authored room-kind preference the old
; C++ (mail-space) op hardcoded.
(define-macro mail-space (?premises)
  (room-of ?premises [k hallway] [k living_room] [k kitchen]))

; (post-letter [k <kind>] <msg> ?premises ?addressee): materialize a <kind> letter
; carrying <msg> in ?premises' mail pile, addressed to ?addressee. The addressee is
; the observable envelope tag the morning-post read gates on, so ONLY ?addressee
; reads it (the household's other residents leave it alone). The .hs delivery
; primitive that replaced the C++ spawn-letter op.
(define-macro post-letter (?kind ?msg ?premises ?addressee)
  (do
    (create-entity ?kind (qual location (mail-space ?premises))): ?ltr
    (set-writing ?ltr ?msg)
    (set-attr ?ltr addressee ?addressee)
    (file-in-stack ?ltr (mail-space ?premises))))

; (plant-letter [k <kind>] <msg> ?premises): the UNADDRESSED sibling of post-letter -
; a letter left in ?premises' pile with no addressee, so the morning-post read skips
; it (nobody is meant to receive it automatically). For a killer's kept forged draft
; planted as discoverable evidence in his own home, or an institutional filing (a
; crime report at a police station) no resident reads.
(define-macro plant-letter (?kind ?msg ?premises)
  (do
    (create-entity ?kind (qual location (mail-space ?premises))): ?ltr
    (set-writing ?ltr ?msg)
    (file-in-stack ?ltr (mail-space ?premises))))
