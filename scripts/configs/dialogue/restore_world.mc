; The restore gauntlet's world (Merlin tests/talkie/restore/): the town at the func tests' founder
; density, lived through the first window and saved on its Sunday afternoon, when the town is awake
; (run_restore_tests.ps1), then restored for every script. What the scripts judge is that a lived,
; saved and restored mind still talks: they read nothing the run happened to do, only what each man's
; own restored memory holds and what the player tells him. Three residents are cast, the first three
; the founding made. No errand takes anyone out of the house, so each is at home when hailed.

(include "../../macros/occasion-macros.mc")

(define-macro restore-founder-density () 0.08)

(define-func restore-founders ()
  (for-each ?b (env-entities [k residential-building])
    (for-each ?unit (spatial ?b parts [k unit] /env)
      (if (chance (restore-founder-density))
          (make-founder-household ?unit (class-for-residence ?b))))))

(define-func restore-startup ()
  (restore-founders)
  (seed_property)
  (initialize-minds)
  (seed-founding-matches (founding-wedding-first-day) 1)
  (seat-founding-heads)
  (found-households)
  (join-parishes)
  (cast first-resident (nth 0 (env-entities [k human])))
  (cast second-resident (nth 1 (env-entities [k human])))
  (cast third-resident (nth 2 (env-entities [k human]))))

(define-list config
  seeds 4242
  start 1700-01-01
  end 1700-12-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup restore-startup
  inhibit want-read-mail-driver want-drink-driver idle-go-home-driver want-putter-driver
          feel-charitable-driver want-worship-driver want-attend-guest-driver
          want-eat-out-pub-driver want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver)
