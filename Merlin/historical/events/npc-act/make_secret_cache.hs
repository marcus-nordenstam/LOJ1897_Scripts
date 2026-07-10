; ----------------------------------------------------------------------------
; make_secret_cache.hs - an NPC with something to hide fashions a secret cache.
;
; When an NPC has REASON to send / receive secret letters (here: a covert lover),
; they carve out a private hiding spot in their home. A hiding-spot is a small
; INTERIOR SUB-SPACE (a hidden `part` of a room or of a host prop, not a loose
; prop). It is THEIRS (create-entity stamps owner = @self, the "you make it,
; you own it" rule; claiming a built-in chamber stamps owner explicitly), so
; only they search it.
;
; HOST-QUALITY LADDER (each tier gates live on "still no hiding spot", so the
; first tier whose host exists in the home wins - effects run in order):
;   1. secret_chamber  - a concealed chamber the manor was BUILT with (seeded
;                        by world-gen in some upper studies); claimed, not made.
;   2. painting_cache  - a cavity behind a hung painting.
;   3. jewelry_box_lining - a false lining in a jewelry box.
;   4. book_cache      - a hollowed-out book.
;   5. floorboard_cache - the always-available loose floorboard in the bedroom.
;
; PURE .hs:
;   - home IS the building, so {@self home ?building} gives it directly, and
;     {?building room [k bedroom]:?bedroom} binds a bedroom they know of;
;   - host discovery walks the home's rooms' `parts` / `contents` env attrs
;     (the same sanctioned walk cohabitant_cache_discovery uses);
;   - (create-entity [k <cache>] (qual parent <host>)) makes the cache-space as
;     a CHILD of its host (a sub-space, not contents);
;   - {@self hiding_spot ?cache} records it - the durable (/rsn, since
;     hiding_spot is a DEFINED relation) self-knowledge that both gates this
;     act (made at most one cache) and seeds the search routine's role.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think make_secret_cache
  (long-term-think)

  (role @self (any_human @self))

  ; Something to hide is the reason - a covert lover (secret letters) or a
  ; standing stow goal (loot, a stained instrument); no cache yet; bind the
  ; home + a bedroom in it (the pattern-binds thread along the (and) spine and
  ; GATE - no home or bedroom => no cache).
  (when (and (or (believes {@self lover ?})
                 (goal? {@self stow}))
             (not (believes {@self hiding_spot ?}))
             (bind {@self home ?building})
             (bind {?building room [k bedroom]:?bedroom})))

  (effects
    ; Tier 1 - claim the home's built-in secret chamber (a hidden sub-space
    ; world-gen seeded; you live here, you know the house's secret).
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?chamber (attr-values ?room parts [k secret_chamber])
        (if (not (believes {@self hiding_spot ?}))
            (do
              (set-attr ?chamber owner @self)
              (begin-belief {@self hiding_spot ?chamber})))))
    ; Tier 2 - a cavity behind a painting.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?painting (attr-values ?room contents [k painting])
        (if (not (believes {@self hiding_spot ?}))
            (do
              (create-entity [k painting_cache] (qual parent ?painting) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 3 - a false lining in a jewelry box.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?box (attr-values ?room contents [k jewelry_box])
        (if (not (believes {@self hiding_spot ?}))
            (do
              (create-entity [k jewelry_box_lining] (qual parent ?box) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 4 - a hollowed-out book.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?book (attr-values ?room contents [k book])
        (if (not (believes {@self hiding_spot ?}))
            (do
              (create-entity [k book_cache] (qual parent ?book) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 5 - the always-available loose floorboard in the bedroom.
    (if (not (believes {@self hiding_spot ?}))
        (do
          (create-entity [k floorboard_cache] (qual parent ?bedroom) (bind ?cache))
          (begin-belief {@self hiding_spot ?cache})))))
