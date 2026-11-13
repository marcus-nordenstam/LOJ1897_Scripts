; The introductions gauntlet (introductions.mc) under the jump clock: the January window, a week,
; on four seeds.

(include "introductions.mc")

(define-list config
  seeds 4242 4243 4244 4245
  start 1700-01-01
  end 1700-02-28
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup introductions-startup)

(define-list gauntlet validate introductions-validate deadline 3)
