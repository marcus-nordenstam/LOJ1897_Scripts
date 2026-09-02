; ----------------------------------------------------------------------------
; make_cache (npc-action) - EXECUTION half: carve the actual hiding spot. The
; deliberation that proposes it lives in make_secret_cache_think.hs; env writes
; (a think must not mutate the world) live here. The act walks the host-quality
; ladder and claims/creates the FIRST available host's cache - the belief-guard
; makes exactly one, in strict priority order:
;   1. secret-chamber    - a concealed chamber the manor was built with; CLAIMED
;                          (owner stamped), never created.
;   2. painting-cache    - a cavity behind a hung painting.
;   3. jewelry-box-lining - a false lining in a jewelry box.
;   4. book-cache        - a hollowed-out book.
;   5. floorboard-cache  - the always-available loose floorboard in the bedroom.
; create-entity stamps owner = @self (the "you make it, you own it" rule);
; {@self hiding-spot ?cache} is the durable self-knowledge the search routine
; (read_secret_letters_think.hs) casts. The cache-kind is a static literal per
; tier because create-entity takes only a syntactic [k <kind>], so the ladder
; stays here rather than a runtime kind threaded through the proposal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self MAKE-CACHE ?building}
  (duration 0)
  (effects
    (bind 0 ?made)
    (spatial ?building parts [k interior-space room] /env): ?rooms
    ; Tier 1 - claim the home's built-in secret chamber.
    (for-each ?room ?rooms
      (for-each ?chamber (spatial ?room parts [k secret-chamber] /env)
        (if (= ?made 0)
            (then
              (set-attr ?chamber owner @self)
              (begin-belief {@self hiding-spot ?chamber})
              (bind 1 ?made)))))
    ; Tier 2 - a cavity behind a painting.
    (for-each ?room ?rooms
      (for-each ?painting (spatial ?room contents [k painting] /env)
        (if (= ?made 0)
            (then
              (create-entity [k painting-cache] ?room ?painting): ?cache
              (begin-belief {@self hiding-spot ?cache})
              (bind 1 ?made)))))
    ; Tier 3 - a false lining in a jewelry box.
    (for-each ?room ?rooms
      (for-each ?box (spatial ?room contents [k jewelry-box] /env)
        (if (= ?made 0)
            (then
              (create-entity [k jewelry-box-lining] ?room ?box): ?cache
              (begin-belief {@self hiding-spot ?cache})
              (bind 1 ?made)))))
    ; Tier 4 - a hollowed-out book.
    (for-each ?room ?rooms
      (for-each ?book (spatial ?room contents [k book] /env)
        (if (= ?made 0)
            (then
              (create-entity [k book-cache] ?room ?book): ?cache
              (begin-belief {@self hiding-spot ?cache})
              (bind 1 ?made)))))
    ; Tier 5 - the always-available loose floorboard in the bedroom. The bedroom
    ; walk plus the hiding-spot guard carves exactly one, same as the tiers above.
    (for-each ?bedroom (spatial ?building parts [k interior-space bedroom] /env)
        (if (= ?made 0)
            (then
              (create-entity [k floorboard-cache] ?bedroom ?bedroom): ?cache
              (begin-belief {@self hiding-spot ?cache})
              (bind 1 ?made))))
    (set-outcome {@self MAKE-CACHE} /succ)))
