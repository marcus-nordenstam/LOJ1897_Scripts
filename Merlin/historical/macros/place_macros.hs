; ----------------------------------------------------------------------------
; place_macros.hs - "am I at <place>" predicates, as define-macros.
;
; These replace the old (self-at ...) C++ op. Each expands to pure belief reads
; over the deliberating NPC's OWN mind (no telepathy, no objective-hierarchy
; peek): home / location / room->building, all self-perceived or learned. The
; macro expander inlines the body at every call site (each (bind ...) keeps its
; own op-memo slot) and gensyms the body-internal ?vars per expansion.
;
; SPATIAL MODEL (the home->address migration):
;   - `home` belief targets the exterior ADDRESS-SPACE (the residence's frontage),
;     not the building. A resident "at home" stands at that frontage, so their
;     {@self location} equals their {@self home} (the INTERIM placement - interior
;     rooms are a later follow-up; at-home gains a room branch then, here).
;   - `location` is the perceptible CURRENT ROOM/space, self-perceived on arrival.
;   - {room building <bldg>} is the reverse-containment belief minted on arrival
;     (perceive_here) + when a building's rooms are learned: it lets a room resolve
;     to its enclosing building purely from belief.
; ----------------------------------------------------------------------------

; (at-home): the NPC is at their own home (its exterior address-space frontage).
; `bind` PRODUCES the free ?home (my home address-space); `believes` is the
; fully-bound existence test ("is ?home my current location") - bind rejects a
; fully-bound field, that is what believes is for.
(define-macro at-home ()
  (and (bind {@self home ?home})
       (believes @self {@self location ?home})))

; (at-place ?place): the NPC is at ?place - either standing AT it directly (a
; frontage / exterior space, e.g. someone else's home address), OR inside a room
; whose enclosing building is ?place (a workplace / venue building). Both arms are
; fully-bound existence tests (?place is the bound argument) -> believes; the room
; arm first PRODUCES the free ?room with bind.
(define-macro at-place (?place)
  (or (believes @self {@self location ?place})
      (and (bind {@self location ?room})
           (believes @self {?room building ?place}))))

; (at-place-kind [k building <leaf>]): the NPC's current room is inside a building
; of the given kind (pub / church / bank / school / social_clubhouse / ...). Both
; clauses PRODUCE a free var (the room, then the kind-cast building), so bind is
; correct here - the `[k ..]:?var` kind-cast is a producing bind, not a constraint.
(define-macro at-place-kind (?kind)
  (and (bind {@self location ?room})
       (bind {?room building ?kind:?bldg})))
