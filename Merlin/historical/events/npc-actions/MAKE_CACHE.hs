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

(npc-action {@self MAKE_CACHE ?building}
  (duration 0)
  (effects
    (bind 0 ?made)
    (spatial ?building parts [k interior_space room] /env): ?rooms
    ; Tier 1 - claim the home's built-in secret chamber.
    (for-each ?room ?rooms
      (for-each ?chamber (spatial ?room parts [k secret_chamber] /env)
        (if (= ?made 0)
            (then
              (set-attr ?chamber owner @self)
              (begin-belief {@self hiding_spot ?chamber})
              (bind 1 ?made)))))
    ; Tier 2 - a cavity behind a painting.
    (for-each ?room ?rooms
      (for-each ?painting (env-content ?room [k painting])
        (if (= ?made 0)
            (then
              (create-entity [k painting_cache] (qual parent ?painting)): ?cache
              (begin-belief {@self hiding_spot ?cache})
              (bind 1 ?made)))))
    ; Tier 3 - a false lining in a jewelry box.
    (for-each ?room ?rooms
      (for-each ?box (env-content ?room [k jewelry_box])
        (if (= ?made 0)
            (then
              (create-entity [k jewelry_box_lining] (qual parent ?box)): ?cache
              (begin-belief {@self hiding_spot ?cache})
              (bind 1 ?made)))))
    ; Tier 4 - a hollowed-out book.
    (for-each ?room ?rooms
      (for-each ?book (env-content ?room [k book])
        (if (= ?made 0)
            (then
              (create-entity [k book_cache] (qual parent ?book)): ?cache
              (begin-belief {@self hiding_spot ?cache})
              (bind 1 ?made)))))
    ; Tier 5 - the always-available loose floorboard in the bedroom. The bedroom
    ; walk plus the hiding_spot guard carves exactly one, same as the tiers above.
    (for-each ?bedroom (spatial ?building parts [k interior_space bedroom] /env)
        (if (= ?made 0)
            (then
              (create-entity [k floorboard_cache] (qual parent ?bedroom)): ?cache
              (begin-belief {@self hiding_spot ?cache})
              (bind 1 ?made))))
    (set-outcome {@self MAKE_CACHE} succ)))
