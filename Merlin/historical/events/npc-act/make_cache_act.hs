; ----------------------------------------------------------------------------
; make_cache (npc-action) - EXECUTION half: carve the actual hiding spot. The
; deliberation that proposes it lives in make_secret_cache_think.hs; env writes
; (a think must not mutate the world) live here. The act walks the host-quality
; ladder and claims/creates the FIRST available host's cache - the belief-guard
; makes exactly one, in strict priority order:
;   1. secret_chamber    - a concealed chamber the manor was built with; CLAIMED
;                          (owner stamped), never created.
;   2. painting_cache    - a cavity behind a hung painting.
;   3. jewelry_box_lining - a false lining in a jewelry box.
;   4. book_cache        - a hollowed-out book.
;   5. floorboard_cache  - the always-available loose floorboard in the bedroom.
; create-entity stamps owner = @self (the "you make it, you own it" rule);
; {@self hiding_spot ?cache} is the durable self-knowledge the search routine
; (read_secret_letters_think.hs) casts. The cache-kind is a static literal per
; tier because create-entity takes only a syntactic [k <kind>], so the ladder
; stays here rather than a runtime kind threaded through the proposal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action make_cache_act
  (act {@self make_cache ?building})
  (duration 0)
  (act-effects
    (bind {?building room [k bedroom]:?bedroom})
    ; Tier 1 - claim the home's built-in secret chamber.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?chamber (attr-values ?room parts [k secret_chamber])
        (if (not (believes {@self hiding_spot ?}))
            (then
              (set-attr ?chamber owner @self)
              (begin-belief {@self hiding_spot ?chamber})))))
    ; Tier 2 - a cavity behind a painting.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?painting (attr-values ?room contents [k painting])
        (if (not (believes {@self hiding_spot ?}))
            (then
              (create-entity [k painting_cache] (qual parent ?painting) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 3 - a false lining in a jewelry box.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?box (attr-values ?room contents [k jewelry_box])
        (if (not (believes {@self hiding_spot ?}))
            (then
              (create-entity [k jewelry_box_lining] (qual parent ?box) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 4 - a hollowed-out book.
    (for-each ?room (attr-values ?building parts [k interior_space room])
      (for-each ?book (attr-values ?room contents [k book])
        (if (not (believes {@self hiding_spot ?}))
            (then
              (create-entity [k book_cache] (qual parent ?book) (bind ?cache))
              (begin-belief {@self hiding_spot ?cache})))))
    ; Tier 5 - the always-available loose floorboard in the bedroom.
    (if (not (believes {@self hiding_spot ?}))
        (then
          (create-entity [k floorboard_cache] (qual parent ?bedroom) (bind ?cache))
          (begin-belief {@self hiding_spot ?cache})))
    (end-act {@self make_cache})))
