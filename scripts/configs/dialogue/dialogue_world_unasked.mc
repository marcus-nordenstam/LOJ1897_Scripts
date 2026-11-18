; The dialogue test world for a man who does not seek anyone out to ask what he wonders: he asks
; only when he is in a talk with the one who can tell him (drivers/ask-wonder-driver.mc).
(include "dialogue_startup.mc")

(define-list config
  seeds 4242
  start 1700-01-24-15
  end 1700-01-31
  clock real
  fps 30
  presented interviewee
  level "Theatres/demo_tech_level_v2.grs"
  startup dialogue-startup
  inhibit classify-wealth
          want-read-mail-driver want-drink-driver idle-go-home-driver sleep-driver want-putter-driver
          feel-charitable-driver want-worship-driver want-attend-guest-driver
          want-eat-out-pub-driver want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-to-know-driver)
