; ----------------------------------------------------------------------------
; make_cache (action) - EXECUTION half: carve the actual hiding spot. The
; deliberation that proposes it lives in make_secret_cache_think.mc; env writes
; (a think must not mutate the world) live here. The act walks the host-quality
; ladder and claims/creates the FIRST available host's cache - the belief-guard
; makes exactly one, in strict priority order:
;   1. secret-chamber    - a concealed chamber the manor was built with; CLAIMED,
;                          never created.
;   2. painting-cache    - a cavity behind a hung painting.
;   3. jewelry-box-lining - a false lining in a jewelry box.
;   4. book-cache        - a hollowed-out book.
;   5. floorboard-cache  - the always-available loose floorboard in the bedroom.
; {@self hiding-spot ?cache} is the durable self-knowledge the search routine
; (read_secret_letters_think.mc) casts. The cache-kind is a static literal per
; tier because create-entity takes only a syntactic [k <kind>], so the ladder
; stays here rather than a runtime kind threaded through the proposal.
; ----------------------------------------------------------------------------


(action {@self MAKE-CACHE ?building}:?MAKE-CACHE
  (motor body)
  (duration 0)
  (effects
    (bind 0 ?made)
    (spatial ?building rooms /env): ?rooms
    ; Tier 1 - claim the home's built-in secret chamber.
    (for-each ?room ?rooms
      (for-each ?chamber (spatial ?room parts [k secret-chamber] /env)
        (if (= ?made 0)
            (then
              ; The chamber is hidden: he sees it only by looking for it on the room it is in.
              (observe /hidden ?room)
              (observe ?chamber): ?known
              (begin-belief {@self hiding-spot ?known})
              (bind 1 ?made)))))
    ; Tier 2 - a cavity behind a painting.
    (for-each ?room ?rooms
      (for-each ?painting (spatial ?room contents [k painting] /env)
        (if (= ?made 0)
            (then
              (create-entity [k painting-cache] @nothing ?painting): ?cache
              (observe /hidden ?painting)
              (observe ?cache): ?known
              (begin-belief {@self hiding-spot ?known})
              (bind 1 ?made)))))
    ; Tier 3 - a false lining in a jewelry box.
    (for-each ?room ?rooms
      (for-each ?box (spatial ?room contents [k jewelry-box] /env)
        (if (= ?made 0)
            (then
              (create-entity [k jewelry-box-lining] @nothing ?box): ?cache
              (observe /hidden ?box)
              (observe ?cache): ?known
              (begin-belief {@self hiding-spot ?known})
              (bind 1 ?made)))))
    ; Tier 4 - a hollowed-out book.
    (for-each ?room ?rooms
      (for-each ?book (spatial ?room contents [k book] /env)
        (if (= ?made 0)
            (then
              (create-entity [k book-cache] @nothing ?book): ?cache
              (observe /hidden ?book)
              (observe ?cache): ?known
              (begin-belief {@self hiding-spot ?known})
              (bind 1 ?made)))))
    ; Tier 5 - the always-available loose floorboard in the bedroom. The bedroom
    ; walk plus the hiding-spot guard carves exactly one, same as the tiers above.
    (for-each ?bedroom (spatial ?building rooms [k bedroom] /env)
        (if (= ?made 0)
            (then
              (create-entity [k floorboard-cache] @nothing ?bedroom): ?cache
              (observe /hidden ?bedroom)
              (observe ?cache): ?known
              (begin-belief {@self hiding-spot ?known})
              (bind 1 ?made))))
    (set-outcome ?MAKE-CACHE /succ)))
