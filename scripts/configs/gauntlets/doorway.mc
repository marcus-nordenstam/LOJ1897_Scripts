; ----------------------------------------------------------------------------
; doorway - a man seen through an open front door: the watcher stands in the street before his
; neighbour's open door, the resident just inside it with an almanac in his hand. Seeing him
; through the doorway, the watcher knows the unit he stands in and what he holds, and where. Every driver
; that would walk either man off is inhibited, so what the watcher learned is still what he knows
; when the run is judged. The funcs are written once here; doorway-jump.mc runs them.
; ----------------------------------------------------------------------------

(include "movement.mc")

(define-func doorway-startup ()
  (seed_property)
  (spatial (head (env-entities [k pub-building])) space /env): ?town
  (movement-nth-home ?town 0): ?resident-home
  (make-human ?resident-home [k lower] [k male]): ?resident
  (cast resident ?resident)
  (movement-open-doors ?resident-home)
  (spatial (spatial ?resident-home building /env) space /env): ?street
  (movement-stand-inside-door ?resident ?resident-home ?street)
  (movement-hand-book ?resident)
  (movement-nth-home ?town 1): ?watcher-home
  (make-human ?watcher-home [k lower] [k male]): ?watcher
  (cast watcher ?watcher)
  (movement-stand-before-door ?watcher ?resident-home ?street)
  (initialize-minds))

(define-func doorway-validate ()
  (cast resident): ?resident
  (cast watcher): ?watcher
  (expect (in-mind ?watcher (substantial (spatial ?resident unit)))
          "watcher: saw the resident through the doorway, but not the unit he stands in")
  (expect (in-mind ?watcher (substantial (movement-right-hand-holds ?resident)))
          "watcher: saw the resident through the doorway, but not the almanac in his hand")
  (expect (in-mind ?watcher (< (distance (movement-right-hand-holds ?resident) (spatial ?resident right-hand)) 1.0))
          "watcher: saw the almanac in the resident's hand, but not where it is"))
