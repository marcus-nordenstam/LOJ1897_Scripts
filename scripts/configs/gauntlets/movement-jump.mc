; The movement gauntlet (movement.mc) under the jump clock: the January and April windows, a
; week each, on four seeds - one child process a seed.

(include "movement.mc")

(define-list config
  seeds 4242 4243 4244 4245
  start 1700-01-01
  end 1700-06-30
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup movement-startup)

(define-list gauntlet validate movement-validate)
