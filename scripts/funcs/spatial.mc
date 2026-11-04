; ----------------------------------------------------------------------------
; spatial.mc - where a thing rests and what a mind has seen of a premises, as content.
;
; A journey has no geometry in it: every leg walks to a SPOT, and the spot's anchor names the
; space he lands in. No rule holds a point.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; ?x is inside ?place, a building or a unit of one.
(define-func within-place (?x ?place)
  (or (spatial ?x building ?place)
      (spatial ?x unit ?place)))

; The building or unit a search for something in ?space walks: ?space itself when it is one, else
; the unit holding it, else the building; @nothing out of doors or for nothing. A unit, not its
; building: the rooms of a rowhouse's other units are reached only through the street.
(define-func place-holding (?space)
  (cond (case (unsubstantial ?space) @nothing)
        (case (or (is-a ?space [k building]) (is-a ?space [k unit])) ?space)
        (case (substantial (tolerate (spatial ?space unit))) (spatial ?space unit))
        (else (tolerate (spatial ?space building)))))

; ?place is one premises - one home, one shop: a unit, or a building holding no unit he knows.
; A wander or a search never spans units: each unit is a household of its own.
(define-func one-premises (?place)
  (or (is-a ?place [k unit])
      (and (is-a ?place [k building])
           (empty (spatial ?place parts [k unit])))))

; ?x is inside ?space: a room, or a building or a unit of one; for an exterior space, out of
; doors in it - a man in a house in the town stands in the house, not in the town's open ground.
(define-func within-space (?x ?space)
  (tolerate (spatial ?x space)): ?here
  (cond (case (not (is-a ?space [k exterior-space]))
              (or (spatial ?x space ?space) (within-place ?x ?space)))
        (case (unsubstantial ?here) @false)
        (else (and (is-a ?here [k exterior-space]) (spatial ?x space ?space)))))

; The free floor spot through ?passage from where @self stands, whether or not he knows the
; space there: in a room the free spot nearest its middle, clear of the way for whoever comes
; through after him; out of doors at least k_passage_clear_out_m out from the doorway, further out or
; to either side when that is taken. A search: the rung that stands him there claims it.
(define-func passage-spot-beyond (?passage)
  (find-spot @self [/beyond ?passage] [/near ?passage] [/at_or_near @self]))

; The space on @self's side of ?passage, where he stands to work it.
(define-func passage-near-side (?passage)
  (spatial ?passage before (spatial @self space)))

; @self stands in the room on his side of ?passage, as he believes it: where a cross of it begins.
(define-func in-near-room (?passage)
  (passage-near-side ?passage): ?near
  (and (substantial ?near) (eq ?near (spatial @self space))))

; The free stance on @self's side of ?passage from which he can reach it, to work it. @fail
; while every such stance is taken. A search: the rung that stands him there claims it.
(define-func passage-stance (?passage)
  (find-spot @self [/before ?passage] [/near ?passage] [/at_or_near @self]
                       [/can_reach ?passage]))

; There is a stance on @self's side of ?passage, though others may hold every one: the door can be
; reached at all, crowd or no crowd.
(define-func passage-stance-exists (?passage)
  (is-spot (find-spot @self [/before ?passage] [/near ?passage] [/at_or_near @self]
                      [/can_reach ?passage] /unclaimed)))

; @self stands in a space of kind ?kind, as he believes it.
(define-func stands-in-room (?kind)
  (tolerate (spatial @self space)): ?here
  (and (substantial ?here) (is-a ?here ?kind)))

; ?place is struck off the search ?find: wandered through without what it sought, or never got into.
(define-func premises-searched (?place ?find)
  (or (substantial (any {@self wander ?place /succ /caused_by ?find}))
      (substantial (any {@self enter-building ?place /fail /caused_by ?find}))))

; The home he believes ?who has, or @nothing.
(define-func home-of (?who)
  (bind @nothing ?home)
  (if (any {?who home ?}): ?homing
    (then (bind ?homing.target ?home)))
  ?home)

; The workplace of the org he believes ?job belongs to, or @nothing.
(define-func job-workplace (?job)
  (bind @nothing ?workplace)
  (if (any {?job org ?}): ?of-org
    (then (bind ?of-org.target ?org)
          (if (any {?org workplace ?}): ?working
            (then (bind ?working.target ?workplace)))))
  ?workplace)

; He knows a room of kind ?kind in ?place, a building or a unit.
(define-func known-room-of (?kind ?place)
  (bind @false ?known)
  (for-each ?room (spatial ?place rooms)
    (if (is-a ?room ?kind)
      (then
        (bind @true ?known)
        (break))))
  ?known)

; The house he has seen at ?x's address: its household's unit, else the premises' building, or
; @nothing.
(define-func seen-house-of (?x)
  (bind @nothing ?house)
  (if (any {?x address}): ?address
    (then (bind (seen-premises-at (address-household ?address.target)) ?house)
          (if (unsubstantial ?house)
            (then (bind (seen-premises-at (address-premises ?address.target)) ?house)))))
  ?house)

; @self stands in a building of kind ?kind, as he believes it.
(define-func stands-in-building (?kind)
  (tolerate (spatial @self building)): ?here
  (and (substantial ?here) (is-a ?here ?kind)))

; Where a thing set down "at ?dest" comes to rest: a free spot where the whole thing fits, on
; the floor of a space or on top of anything else. @fail while no spot is free - the asking rung
; polls until one is. A search: the rung that sets the thing down claims it, (claim .. ?item).
(define-func rest-spot (?dest ?item)
  (if (is-a ?dest [k space])
      (then (find-spot ?item [/on_floor_of ?dest]))
      (else (find-spot ?item [/on_top_of ?dest]))))

; Where world-gen sets a new ?kind down in ?bldg: a free spot on a writing-desk or table in
; any of its rooms, else a room's floor. Mindless: the world is read as it stands and
; nothing is claimed - each call sees what the calls before it placed.
(define-func seed-rest-spot (?place ?kind)
  (spatial ?place room /env): ?found
  (for-each ?room (spatial ?place rooms /env)
    (if (is-spot ?found) (then (break)))
    (for-each ?surface (spatial ?room contents [k furniture] /env)
      (if (or (is-a ?surface [k writing-desk]) (is-a ?surface [k table]))
        (then
          (if (find-spot ?kind [/on_top_of ?surface]): ?spot
            (then
              (bind ?spot ?found)
              (break)))))))
  ?found)

; ?barrier bars the way as @self believes it: shut and unbroken. @nothing bars nothing.
(define-func barred (?barrier)
  (and (substantial ?barrier)
       (substantial (any {?barrier opening-status [k shut]}))
       (unsubstantial (any {?barrier integrity [k broken]}))))

; ?barrier bars the way and @self believes it locked: opening it will not do.
(define-func barred-locked (?barrier)
  (and (barred ?barrier)
       (substantial (any {?barrier lock-status [k locked]}))))

; The place a business or a household holds in ?bldg: its one unit, or the building itself when
; it holds none. A building of several units does not say which of them - the caller must.
(define-func premises-place (?bldg)
  (spatial ?bldg parts [k unit] /env): ?units
  (expect (<= (count ?units) 1) "premises-place: a building of several units names no one premises")
  (cond (case (empty ?units) ?bldg)
        (case (= (count ?units) 1) (head ?units))
        (else @fail)))

; Where @self stands inside a space: a free spot on its floor - in a room the one nearest its
; middle, out of doors the one nearest him. A search: the rung that stands him there claims it.
(define-func stand-spot-in (?space)
  (find-spot @self [/on_floor_of ?space]
                       [/near (flip (is-a ?space [k exterior-space]) @self ?space)] [/at_or_near @self]): ?spot
  (check (or (not (is-spot ?spot)) (= (spatial ?spot space) ?space)))
  ?spot)

; Where @self stands to be BY a thing: the free floor spot of its space nearest it, within reach
; of it; @fail while every such stance is taken. Not the spot before its face - a thing set on
; furniture has the furniture there.
(define-func stand-spot-by (?ent)
  (spatial ?ent space): ?space
  (find-spot @self [/on_floor_of ?space] [/near ?ent] [/at_or_near @self]
                       [/can_reach ?ent]): ?spot
  (check (or (not (is-spot ?spot)) (= (spatial ?spot space) ?space)))
  ?spot)

; Where @self stands to face a man: the free floor before his front nearest him, else beside him
; when his front is taken - within reach of him either way.
(define-func stand-spot-before (?person)
  (find-spot @self [/in_front_of ?person] [/near ?person] [/at_or_near @self]
                       [/can_reach ?person]): ?front
  (if (is-spot ?front) (then ?front) (else (stand-spot-by ?person))))

; Where @self stands to talk with a man: before him, face to face, as stand-spot-before stands
; him; that taken, the free floor of his space nearest him - within his hearing, not his reach.
(define-func earshot-spot-of (?person)
  (find-spot @self [/in_front_of ?person] [/near ?person] [/at_or_near @self]
                       [/can_reach ?person]): ?front
  (if (is-spot ?front)
      (then ?front)
      (else (bind (spatial ?person space) ?space)
            (find-spot @self [/on_floor_of ?space] [/near ?person] [/at_or_near @self]))))

; The box @self heads for: the one he sees, else the one he remembers. A structure he never had
; a box for is find-building's.
(define-func known-box (?ent)
  (tolerate (spatial ?ent bounds)): ?seen
  (tolerate (spatial ?ent bounds /most-recent-memory)): ?remembered
  (cond (case (substantial ?seen) ?seen)
        (case (substantial ?remembered) ?remembered)
        (else @nothing)): ?known
  ?known)

; ----------------------------------------------------------------------------
; seen-premises-at ?address - the building or unit @self has PERCEIVED at that address, or
; @nothing. The negative twin of the role that joins a house to an address: a role can
; join on a value, but a NEGATIVE role reads the per-mind cache alone and has no binding
; env to join with - so "no house I have seen stands there" is asked as a walk.
; ----------------------------------------------------------------------------

(define-func seen-premises-at (?address)
  (bind @nothing ?found)
  (for-each ?address-of-premises (every {? address ?address})
    (bind ?address-of-premises.subject ?p)
    (if (and (or (is-a ?p [k building]) (is-a ?p [k unit]))
             (observed ?p))
      (then
        (bind ?p ?found)
        (break))))
  ?found)

; The building ?place is, or stands in: itself for a building, else the building that holds it.
(define-func building-of (?place)
  (flip (is-a ?place [k building]) ?place (spatial ?place building)))

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
