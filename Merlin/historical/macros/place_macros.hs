; ----------------------------------------------------------------------------
; place_macros.hs - "am I at <place>" predicates, as define-macros.
;
; These replace the old (self-at ...) C++ op. Each expands to pure belief reads
; over the deliberating NPC's OWN mind (no telepathy, no objective-hierarchy
; peek): home / location / room->building, all self-perceived or learned. The
; macro expander inlines the body at every call site (each (bind ...) keeps its
; own op-memo slot) and gensyms the body-internal ?vars per expansion.
;
; SPATIAL MODEL (the address-on-the-premise model):
;   - `home` belief targets the BUILDING directly (the address lives ON the
;     premise: building.address -> road, building.address_number -> int; there is
;     no street_space frontage box). A resident is "at home" when their current
;     room resolves to that building - exactly the at-place test against the home.
;   - `location` is the perceptible CURRENT ROOM/space, self-perceived on arrival.
;   - {room building <bldg>} is the reverse-containment belief minted on arrival
;     (perceive_here) + when a building's rooms are learned: it lets a room resolve
;     to its enclosing building purely from belief.
; ----------------------------------------------------------------------------

; (at-home): the NPC is at their own home BUILDING. `bind` PRODUCES the free
; ?home (my home building); then it is exactly (at-place ?home) - standing at the
; building directly OR inside a room whose enclosing building is the home. Reuses
; at-place (nested macros re-expand) rather than re-reading {@self location}.
(define-macro at-home ()
  (and (bind {@self home ?home})
       (at-place ?home)))

; (at-place ?place): the NPC is at ?place. Bind {@self location ?loc} ONCE, then
; either ?loc IS ?place (standing at it directly - a building / exterior space) OR
; ?loc is a room whose enclosing building is ?place (a workplace / venue building).
(define-macro at-place (?place)
  (and (bind {@self location ?loc})
       (or (= ?loc ?place)
           (believes @self {?loc building ?place}))))

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
