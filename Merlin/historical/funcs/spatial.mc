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
(define-func front-park-point (?venue)
  (spatial ?venue bounds /env): ?vb
  (spatial @self bounds /env): ?sb
  (vec-add (bounds-position ?vb)
           (vec-mul (bounds-axis ?vb)
                    (+ (bounds-extent ?vb)
                       (* (bounds-extent ?sb) (front_park_clearance))))))

; Is @self standing at ?venue's threshold - OUTSIDE it, and within the band of the
; stand-off point? Being inside the venue ends the threshold however near the door.
(define-func at-threshold (?venue)
  (spatial @self bounds /env): ?sb
  (and (not (spatial @self building ?venue))
       (<= (vec-distance (bounds-position ?sb) (front-park-point ?venue))
           (at_threshold_band_m))))
