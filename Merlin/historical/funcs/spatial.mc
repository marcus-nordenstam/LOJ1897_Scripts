; ----------------------------------------------------------------------------
; spatial.mc - placement geometry, as content.
;
; This was C++ (t_environment::front_park_point / front_park / at_threshold, and the
; (front-park) op). None of it belonged there: standing off a venue's face by a body
; depth is a PLACEMENT POLICY, and a policy is content. The engine's job is only to
; expose the box - (bounds-position), (bounds-axis), (bounds-extent) - and the vector
; arithmetic to combine them.
;
; Both funcs read /env. Bounds are a perception SIGNAL, not memory - the mind plane only
; answers for a box you are looking at RIGHT NOW - so a stand-off point for a venue you are
; still walking toward has to come from ground truth. That is what the C++ these replace
; did, and it is why the find-building lane already carries the env-read waiver.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; The world point to stand at when approaching ?venue: out from its centre along its
; forward axis, clear of its own half-depth, plus @self's half-depth scaled by the
; clearance tunable (a broader body stands further back).
;
; A venue with NO box has no such point, and saying so is the whole of the guard: the
; vector ops read a non-vector as the ZERO vector, so arithmetic on a failed bounds read
; hands back the world ORIGIN as a perfectly substantial point - and WALK relocates the
; body there, permanently. @fail is the honest answer and WALK's own (check ..) catches it.
(define-func front-park-point (?venue)
  (spatial ?venue bounds /env): ?vb
  (spatial @self bounds /env): ?sb
  (check (substantial ?vb))
  (if (unsubstantial ?vb)
      (then @fail)
      (else (vec-add (bounds-position ?vb)
                     (vec-mul (bounds-axis ?vb)
                              (+ (bounds-extent ?vb)
                                 (* (bounds-extent ?sb) (front_park_clearance))))))))

; Is @self standing at ?venue's threshold - OUTSIDE it, and within the band of the
; stand-off point? Being inside the venue ends the threshold however near the door.
; A boxless venue is never at hand: without the bounds test the distance collapses to
; zero and EVERY actor stands at the threshold of a place that is not there.
(define-func at-threshold (?venue)
  (spatial @self bounds /env): ?sb
  (spatial ?venue bounds /env): ?vb
  (and (substantial ?vb)
       (not (spatial @self building ?venue))
       (<= (vec-distance (bounds-position ?sb) (front-park-point ?venue))
           (at_threshold_band_m))))

; ----------------------------------------------------------------------------
; unplaced ?place - @self knows OF ?place but cannot route to it, so the journey has to
; start by finding it. The two kinds of place are asked DIFFERENT questions because the
; travel primitives reach them differently:
;   a ROOM is entered through the building it sits in, and @self only knows that from
;     the immutable containment his own index carries - @unknown until he has SEEN the
;     room, which happens from inside. So: (spatial ?place building).
;   a STRUCTURE is walked to by GROUND TRUTH - (front-park-point ..) reads /env bounds on
;     purpose, since you set out for a venue you are not looking at. Whether @self has
;     seen it is beside the point; what blocks the route is the place not being REAL.
;     An address off a page is an imagined building until it fuses with one.
; ----------------------------------------------------------------------------

(define-func unplaced (?place)
  (if (is-a ?place [k interior-space])
      (then (unsubstantial (spatial ?place building)))
      (else (is-irrealis ?place))))

; ----------------------------------------------------------------------------
; seen-premises-at ?address - the building @self has PERCEIVED at that premises address,
; or @nothing. The negative twin of the role that joins a house to an address: a role can
; join on a value, but a NEGATIVE role reads the per-mind cache alone and has no binding
; env to join with - so "no house I have seen stands there" is asked as a walk.
; ----------------------------------------------------------------------------

(define-func seen-premises-at (?address)
  (bind @nothing ?found)
  (for-each ?rel (every {? address ?address})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p [k building])
             (observed ?p))
      (then
        (bind ?p ?found)
        (break))))
  ?found)
