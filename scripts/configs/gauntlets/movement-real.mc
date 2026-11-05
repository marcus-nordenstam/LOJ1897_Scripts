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

; Every errand but the journeys judged is inhibited - thirst, fatigue and work are what move these
; men - and idle-go-home too, so it is go-to-bed that takes the homebody home.
(define-list gauntlet validate movement-validate deadline 15
  inhibit feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver idle-go-home-driver)
