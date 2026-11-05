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

; Every errand but the journeys judged is inhibited - thirst, fatigue and work are what move these
; men - and idle-go-home too, so it is go-to-bed that takes the homebody home.
(define-list gauntlet validate movement-validate deadline 15
  inhibit feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver idle-go-home-driver)
