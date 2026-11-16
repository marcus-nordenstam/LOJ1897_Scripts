; The talkie dialogue suite's world: the level and the few people its scripts talk to or about, made
; at the start and living nothing before it. talkie brings it up with no .msb, so every man knows only
; what his making gave him and what a script's (@do ..) lines implant - nothing a run lived can move
; an answer. It stands at three on a Sunday afternoon.
; interviewee: the man every script talks to, lower class, English, in a home with a bedroom.
; bedroom: that bedroom. study: a study in another building.
; seen-woman: a woman in a home of her own, whom the interviewee has never seen.
; Nobody reckons his wealth, so the class a man is made with stands, and a script's implanted class
; holds from its first step. No errand takes anyone out of the house, so the interviewee is at home
; and free when the player hails him.

; The first room of ?room-kind in a unit of a residential building other than ?not-in.
(define-func dialogue-room-in-a-home (?room-kind ?not-in)
  (bind @nothing ?found)
  (for-each ?b (env-entities [k residential-building])
    (if (neq ?b ?not-in)
        (then
          (for-each ?unit (spatial ?b parts [k unit] /env)
            (for-each ?room (spatial ?unit rooms /env)
              (if (eq (kind ?room) ?room-kind)
                  (then (bind ?room ?found) (break))))
            (if (substantial ?found) (then (break))))))
    (if (substantial ?found) (then (break))))
  (check (substantial ?found))
  ?found)

(define-func dialogue-nationality (?h ?nat)
  (enter-mind ?h)
  (end-belief (any {@self nationality ?}))
  (begin-belief {@self nationality ?nat})
  (exit-mind))

(define-func dialogue-startup ()
  (seed_property)
  (dialogue-room-in-a-home [k bedroom] @nothing): ?bedroom
  (spatial ?bedroom unit /env): ?his-home
  (make-human ?his-home [k lower] [k male]): ?man
  (set-attr ?man name [n Wilbur Parker])
  (set-attr ?man birth-date (create-date 1663 7 11))
  (dialogue-nationality ?man [k english])
  (cast interviewee ?man)
  (cast bedroom ?bedroom)
  (head (env-entities [k study])): ?study
  (check (substantial ?study))
  (cast study ?study)
  (dialogue-room-in-a-home [k bedroom] (spatial ?his-home building /env)): ?her-bedroom
  (make-human (spatial ?her-bedroom unit /env) [k lower] [k female]): ?woman
  (set-attr ?woman name [n Zelie Dupre])
  (cast seen-woman ?woman)
  (initialize-minds))

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
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver)
