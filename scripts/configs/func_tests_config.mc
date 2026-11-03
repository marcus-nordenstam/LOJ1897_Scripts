; The func-test run config: the standard town at a lower founder density, so one window of it
; runs in well under a minute. A func test asserts a contract, not a town, and every test fires
; daily, so a small town and the January window are enough.

(define-macro func-tests-founder-density () 0.08)

(define-func func-tests-founders ()
  (for-each ?b (env-entities [k residential-building])
    (for-each ?unit (spatial ?b parts [k unit] /env)
      (if (chance (func-tests-founder-density))
          (make-founder-household ?unit (class-for-residence ?b))))))

(define-func func-tests-startup ()
  (func-tests-founders)
  (seed_property)
  (initialize-minds)
  (wed-founders)
  (seat-founding-heads)
  (found-households)
  (join-parishes))

(define-list config
  seeds 4242
  start 1700-01-01
  end 1700-12-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup func-tests-startup)
