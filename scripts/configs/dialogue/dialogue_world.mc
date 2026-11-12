; The talkie dialogue suite's fixture: the town at the func tests' founder density, the first founder
; cast as the `interviewee` every scenario talks to. A scenario seeds what it needs into his mind
; itself ((@do ..) lines), so the world stays one and the scenarios stay apart. msim saves it on the
; Sunday afternoon of the first window (tests/talkie/run_dialogue_tests.ps1), when the town is awake.

(include "../../macros/occasion-macros.mc")

(define-macro dialogue-founder-density () 0.08)

(define-func dialogue-founders ()
  (for-each ?b (env-entities [k residential-building])
    (for-each ?unit (spatial ?b parts [k unit] /env)
      (if (chance (dialogue-founder-density))
          (make-founder-household ?unit (class-for-residence ?b))))))

(define-func dialogue-startup ()
  (dialogue-founders)
  (seed_property)
  (initialize-minds)
  (seed-founding-matches (founding-wedding-first-day) 1)
  (seat-founding-heads)
  (found-households)
  (join-parishes)
  (cast interviewee (head (env-entities [k human]))))

(define-list config
  seeds 4242
  start 1700-01-01
  end 1700-12-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup dialogue-startup)
