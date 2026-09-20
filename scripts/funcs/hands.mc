; ----------------------------------------------------------------------------
; hands.mc - the grip edge, written ONCE.
;
; A thing is held by a HAND and let go AT A PLACE, and both of those are writes on
; the spatial index - the same two writes at either LOD, because two hands is two
; things carried whoever is watching (action_unification_plan.md 5.2 finding 3).
; GRASP and STACK-TAKE take; UNGRASP and PUT release. The PICTURE of it - the socket
; the thing hangs on, the transform it comes to rest at - is the presentation wall's
; and lives in funcs/presentation.mc.
;
; These are the funcs the isim handlers' env-writing halves were going to make in
; mx_* calls, and the reason there is nothing new underneath them: the hsim bodies
; were already on the spatial index, so the port is a re-homing rather than a
; rewrite (5.6).
; ----------------------------------------------------------------------------

; The hand closes: the grip edge points at ?hand, and @self sees what he is holding.
; (observe ..) is what makes the grip a fact in his own mind and not only in the
; world - a man knows what is in his hand.
(define-func grip-into-hand (?item ?hand)
  (spatial-write ?item gripped-by ?hand /env)
  (observe ?item))

; The hand opens: the grip edge is cleared and the thing is somewhere - ?dest, the cell
; the task claimed for it at unpresented LOD and the point the reach chose at presented
; LOD; relocate takes either and files the thing in the space it lands in. BOTH writes
; are needed: clearing the grip without setting the thing down leaves it held by nothing
; and standing nowhere.
(define-func release-grip (?item ?dest)
  (spatial-write ?item gripped-by @nothing /env)
  (relocate ?item ?dest)
  (observe ?item))

; Where a thing released from ?hand comes to rest: the hand's own world position,
; dropped by its half-height so the thing's BOTTOM sits on the surface rather than
; its centre - which is the "floating" gap, and the same bottom-anchoring the spawn
; path does. A handless hand has no such point, and the zero vector is not an
; acceptable answer: the vector ops read a failed geometry read as the ORIGIN, so
; the glass would be placed at the centre of the world.
(define-func hand-rest-point (?hand)
  (spatial ?hand bounds /env): ?hb
  (check (substantial ?hb))
  (if (unsubstantial ?hb)
      (then @fail)
      (else (vec-sub (bounds-position ?hb)
                     (vec-mul (floats 0.0 1.0 0.0) (bounds-extent ?hb))))))
