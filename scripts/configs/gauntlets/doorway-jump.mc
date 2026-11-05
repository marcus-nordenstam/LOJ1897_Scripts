; The doorway gauntlet (doorway.mc) under the jump clock: the January window, a week, on four seeds.

(include "doorway.mc")

(define-list config
  seeds 4242 4243 4244 4245
  start 1700-01-01
  end 1700-02-28
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup doorway-startup)

(define-list gauntlet validate doorway-validate deadline 15
  inhibit want-drink-driver idle-go-home-driver want-read-mail-driver sleep-driver
          want-putter-driver feel-charitable-driver want-worship-driver want-attend-guest-driver)
