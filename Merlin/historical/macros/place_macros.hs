; ----------------------------------------------------------------------------
; place_macros.hs - "am I at <place>" predicates, as define-macros.
;
; These replace the old (self-at ...) C++ op. Each expands to a self-read over the
; deliberating NPC's OWN whereabouts (no telepathy, no objective-hierarchy peek). The
; macro expander inlines the body at every call site (each (bind ...) keeps its own
; op-memo slot) and gensyms the body-internal ?vars per expansion.
;
; TWO CRISP PRIMITIVES, split from the old vague (at-place ?place) - "place" conflated
; "a building I am inside" with "a room I am standing in", forcing every gate to carry
; both tests and go wrong whenever a target's granularity was ambiguous:
;   - (in-building ?b): I am physically inside building ?b. Resolved by current-building
;     (my location -> its enclosing building via the env parent walk - the honest "which
;     building am I standing in", the same self-read at-place-kind / can-drink use). True
;     whether I stand in one of ?b's rooms OR directly at ?b (a room-less shell). This is
;     the whereabouts test for every VENUE and HOME (all buildings). It does NOT read the
;     {room building ?b} reverse belief: that is minted only by the room-teach seam, and
;     perceiving a building's parts mints the FORWARD {building room} alone, tripping the
;     seam's already-knows-a-room early-return so the reverse never lands - which used to
;     strand a worker physically inside his workplace unable to prove he was there.
;   - (in-room ?r): I am standing in the SPACE ?r exactly (my location IS ?r). The
;     room-granularity test - for a target that is a room, not a building.
;
; SPATIAL MODEL (the address-on-the-premise model): `home` targets the BUILDING directly
; (the address lives ON the premise); `location` is the perceptible CURRENT ROOM/space,
; self-perceived on arrival.
; ----------------------------------------------------------------------------

; (in-building ?b): the NPC is physically inside building ?b (standing in any of its
; rooms, or directly at it when it is a room-less shell). current-building is fail when
; the NPC is outside all spaces (front-parked at a building's door counts as OUTSIDE, so
; is-inside is correctly false until a room is entered).
(define-macro in-building (?b)
  (= (current-building @self) ?b))

; (in-room ?r): the NPC is standing in the space ?r exactly. Binds {@self location ?loc}
; (also gates on HAVING a location - a front-parked NPC outside all spaces has none) and
; tests ?loc IS ?r.
(define-macro in-room (?r)
  (and (bind {@self location ?loc})
       (= ?loc ?r)))

; (at-workplace ?wp): the NPC is at their workplace. A workplace target is granularity-
; MIXED by domain: a trade/profession seats it at the premises BUILDING (shop / office /
; factory - reached by entering a room, so in-building), while a gentleman's household
; seats it at a ROOM (his study - reached by standing in it, so in-room). One honest OR
; over the two crisp primitives, named so the mixed target is explicit, not smuggled into
; a vague "place".
(define-macro at-workplace (?wp)
  (or (in-building ?wp)
      (in-room ?wp)))

; (at-home): the NPC is at their own home BUILDING. `bind` PRODUCES the free ?home (my
; home building); then it is exactly (in-building ?home).
(define-macro at-home ()
  (and (bind {@self home ?home})
       (in-building ?home)))

; (at-place-kind [k building <leaf>]): the NPC is currently in a building of the given
; kind (pub / church / bank / shop / school / social_clubhouse / ...). Uses the actor's
; OWN current building (current-building resolves location -> enclosing building, whether
; location is stored as the building itself or a room inside it) - self-knowledge, not
; telepathy. Mirrors can-drink; robust to room-less venues where location IS the building
; (the room -> building bind form alone missed those, stranding the buy/dine lanes there).
(define-macro at-place-kind (?kind)
  (is-a (current-building @self) ?kind))

; (can-drink ?actor): is ?actor AT a pub? (drinking to excess is a pub activity;
; the craver elsewhere must first travel to one). Folds the old C++ op -
; building_of_location(current_location) is-a pub.
(define-macro can-drink (?actor)
  (is-a (current-building ?actor) [k building pub]))
