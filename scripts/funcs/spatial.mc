; ----------------------------------------------------------------------------
; spatial.mc - where a thing rests and what a mind has seen of a premises, as content.
;
; A journey has no geometry in it: the coarse leg walks to a venue's bounds HANDLE (the
; engine lands a traveller before a structure's front face), and the near-field leg claims
; a stand cell in front of the venue once it is seen. No rule holds a point.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; ?x is inside ?place, a building or a unit of one.
(define-func within-place (?x ?place)
  (or (spatial ?x building ?place)
      (spatial ?x unit ?place)))

; Where a thing set down "at ?dest" comes to rest: a claimed spot where the whole thing fits,
; on the floor of a space or on top of anything else. @fail while no spot is free - the
; asking rung polls until one is - and the claim is the asking rung's: it is released when
; that rung ceases, so no act has to give it back.
(define-func rest-spot (?dest ?item)
  (if (is-a ?dest [k space])
      (then (maintain-claim-spot ?item [/on_floor_of ?dest]))
      (else (maintain-claim-spot ?item [/on_top_of ?dest]))))

; Where world-gen sets a new ?kind down in ?bldg: a free spot on a writing-desk or table in
; any of its rooms, else a room's floor. Mindless: the world is read as it stands and
; nothing is claimed - each call sees what the calls before it placed.
(define-func seed-rest-spot (?place ?kind)
  (spatial ?place room /env): ?found
  (for-each ?room (spatial ?place parts [k interior-space room] /env)
    (if (is-spot ?found) (then (break)))
    (for-each ?surface (spatial ?room contents [k loose-furniture] /env)
      (if (or (is-a ?surface [k writing-desk]) (is-a ?surface [k table]))
        (then
          (if (find-spot ?kind [/on_top_of ?surface]): ?spot
            (then
              (bind ?spot ?found)
              (break)))))))
  ?found)

; @self could stand in ?space: a free floor spot his size, asked without claiming it.
(define-func can-stand-in (?space)
  (is-spot (find-spot @self [/on_floor_of ?space] [/near @self] [/at_or_near @self])))

; The space of kind ?kind that ?place - a building or a unit - holds itself, nearest @self, that
; he knows and has floor free to stand on, or @nothing. One whose floor has no room for him - too
; low a storey, or full - is passed over.
(define-func nearest-standable (?place ?kind)
  (bind @nothing ?space)
  (bind -1.0 ?best)
  (for-each ?r (spatial ?place parts ?kind)
    (if (can-stand-in ?r)
      (then
        (bind (distance @self ?r) ?d)
        (if (or (< ?best 0.0) (< ?d ?best))
          (then
            (bind ?r ?space)
            (bind ?d ?best))))))
  ?space)

; The threshold of ?place, both ways: the main entrance it holds itself, else any entrance of
; its own - the first with floor for him. @nothing when none has. A building's are the entrances
; its units share; a unit's are its own door.
(define-func entrance-space (?place)
  (nearest-standable ?place [k entrance main-entrance]): ?main
  (if (substantial ?main)
      (then ?main)
      (else (nearest-standable ?place [k interior-space entrance]))))

; Where a man steps into ?place: its entrance, else its nearest room with floor for him.
(define-func entry-space (?place)
  (entrance-space ?place): ?way
  (if (substantial ?way)
      (then ?way)
      (else (nearest-standable ?place [k interior-space room]))))

; @self knows every part of ?kind ?place has.
(define-func knows-every (?place ?kind)
  (>= (count (spatial ?place parts ?kind))
      (count (spatial ?place parts ?kind /env))))

(define-func knows-every-way-in (?place)
  (and (knows-every ?place [k interior-space entrance])
       (knows-every ?place [k interior-space room])))

; Standing at ?place's door he sees what lies behind it: the entrances and rooms it holds itself.
(define-func look-through-door (?place)
  (for-each ?way (spatial ?place parts [k interior-space entrance] /env)
    (observe ?way))
  (for-each ?way (spatial ?place parts [k interior-space room] /env)
    (observe ?way)))

; ?bldg is entered as a whole: through an entrance its units share, or - holding no units - as
; its own one household. A building of units without a shared entrance is entered unit by unit,
; each through its own door.
(define-func enters-as-building (?bldg)
  (or (not (empty (spatial ?bldg parts [k interior-space entrance] /env)))
      (empty (spatial ?bldg parts [k unit] /env))))

; The place a business or a household holds in ?bldg: its one unit, or the building itself when
; it holds none. A building of several units does not say which of them - the caller must.
(define-func premises-place (?bldg)
  (spatial ?bldg parts [k unit] /env): ?units
  (expect (<= (count ?units) 1) "premises-place: a building of several units names no one premises")
  (cond (case (empty ?units) ?bldg)
        (case (= (count ?units) 1) (head ?units))
        (else @fail)))

; Where @self stands inside a space: a claimed spot on its floor, the one nearest him.
; Polled like rest-spot, and likewise the asking rung's claim.
(define-func stand-spot-in (?space)
  (maintain-claim-spot @self [/on_floor_of ?space] [/near @self] [/at_or_near @self]))

; Where @self stands to be BY a thing: the free floor spot of its space nearest it. Not the
; spot before its face - a thing set on furniture has the furniture there.
(define-func stand-spot-by (?ent)
  (maintain-claim-spot @self [/on_floor_of (spatial ?ent space)] [/near ?ent] [/at_or_near @self]))

; The box @self heads for when far from ?ent: the one he sees, else the one he remembers, and
; for a structure he never had a box for, the world's - where a building stands is public.
(define-func known-box (?ent)
  (tolerate (spatial ?ent bounds)): ?seen
  (tolerate (spatial ?ent bounds /most-recent-memory)): ?remembered
  (cond (case (substantial ?seen) ?seen)
        (case (substantial ?remembered) ?remembered)
        (case (is-a ?ent [k structure]) (spatial ?ent bounds /env))
        (else @nothing)): ?known
  ?known)

; ----------------------------------------------------------------------------
; seen-premises-at ?address - the building @self has PERCEIVED at that premises address,
; or @nothing. The negative twin of the role that joins a house to an address: a role can
; join on a value, but a NEGATIVE role reads the per-mind cache alone and has no binding
; env to join with - so "no house I have seen stands there" is asked as a walk.
; ----------------------------------------------------------------------------

(define-func seen-premises-at (?address)
  (bind @nothing ?found)
  (for-each ?address-of-premises (every {? address ?address})
    (bind ?address-of-premises.subject ?p)
    (if (and (is-a ?p [k building])
             (observed ?p))
      (then
        (bind ?p ?found)
        (break))))
  ?found)

; building-at ?address - the building that stands at that premises address, or @nothing.
; The world's answer, not a mind's: for the town's own services and the acts that file and
; re-point its records.
(define-func building-at (?address)
  (bind @nothing ?found)
  (for-each ?b (env-entities [k building])
    (if (= (attr ?b address) ?address)
      (then
        (bind ?b ?found)
        (break))))
  ?found)
