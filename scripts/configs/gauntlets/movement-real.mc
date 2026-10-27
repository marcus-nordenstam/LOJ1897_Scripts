; The movement gauntlet (movement.mc) under the real clock: one day, frame by frame at a locked
; dt, presented round the regular - he walks the navmesh, and so does whoever is within the
; bubble's range of him; the rest relocate at their walks' caps.

(include "movement.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented regular
  level "Theatres/demo_tech_level_v2.grs"
  startup movement-startup)

(define-list gauntlet validate movement-validate)
