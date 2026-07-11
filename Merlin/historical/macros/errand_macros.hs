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
; Macros expand in-place, so these are used INSIDE an event's (cont-fire-effects
; ...) / (act-effects ...) block. The VENUE ROLE itself is still cast inline in the
; event (a role clause cannot be macro-generated), filtered to the venue kind and
; scored by proximity - the macros take the resulting KNOWN ?venue var (never a
; world scan; knowledge-honest by construction).
; ----------------------------------------------------------------------------

; (route-to-venue-then-act ?venue ?goal): the STAGE-5 TWO-ARM go/dwell decision as ONE
; effect. ?venue is a BUILDING; go_act now front-parks a building (arrive OUTSIDE) and
; enters a ROOM, so reaching a venue is two arms:
;   1. AT ?venue (in-building: inside one of its rooms) -> latch the on-site act-goal
;      {@self <goal>} (the matching (npc-act ...) drains it).
;   2. Not inside, but I KNOW a room of ?venue ({?venue room ?room}, pre-taught for
;      home/workplace or learnt on a prior visit / the front-park entrance seam) -> (go
;      ?room) to step inside. All NPCs bind the same first room, so co-presence converges.
;   3. Know no room yet -> (go ?venue) front-parks it; the arrival entrance seam teaches
;      its first room, so arm 2 fires next cycle. This is what makes a first visit work.
;
;   ; in the think, after casting a (role ?venue [k building church] (select ...)):
;   (cont-fire-effects (route-to-venue-then-act ?venue worship))
(define-macro route-to-venue-then-act (?venue ?goal)
  (if (in-building ?venue)
      (begin-goal {@self ?goal})
      (if (bb-none ?venue approached)
          (excl-goal {@self go ?venue})
          (if (bind {?venue room ?room})
              (excl-goal {@self go ?room})
              (excl-goal {@self go ?venue})))))

; (go-into ?venue): the STAGE-5 two-arm ENTER of a building, for the go/dwell-split
; errands whose own dwell rule owns the on-site act (worship, drink, work, meals, the
; doc-errands, ...). go_act front-parks a building, so heading to a venue is: if I KNOW a
; room of ?venue -> (go ?room) to step inside ((in-building ?venue) then holds, so the dwell
; rule fires and co-presence converges on the shared first room); else -> (go ?venue) to
; front-park it, whose entrance seam teaches its first room so the enter arm fires next
; cycle. Replaces a bare (excl-goal {@self go ?venue}), which now only front-parks.
; NOTE: a SURVEY that WANTS to stay outside (find_building) keeps the bare go - do not
; wrap it. A dest already a ROOM is entered directly - also keep the bare go there.
;
; ALWAYS FRONT-PARK FIRST: arm 1 front-parks the building (re-observing its state each
; visit); arm 2 enters a room only once the per-trip `approached` flag is set (by the
; front-park). So even a pre-known workplace is re-observed on every commute.
(define-macro go-into (?venue)
  (if (bb-none ?venue approached)
      (excl-goal {@self go ?venue})
      (if (bind {?venue room ?room})
          (excl-goal {@self go ?room})
          (excl-goal {@self go ?venue}))))

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
      (read-doc-record ?kind ?rec (building ?b))
      (begin-belief {@self ?label ?b}))))
