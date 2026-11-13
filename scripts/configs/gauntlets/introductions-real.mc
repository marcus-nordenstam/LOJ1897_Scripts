; The introductions gauntlet (introductions.mc) under the real clock: a morning, frame by frame at a
; locked dt, presented round the mother.

(include "introductions.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-12
  clock real
  fps 10
  presented mother
  level "Theatres/demo_tech_level_v2.grs"
  startup introductions-startup)

(define-list gauntlet validate introductions-validate deadline 3)
