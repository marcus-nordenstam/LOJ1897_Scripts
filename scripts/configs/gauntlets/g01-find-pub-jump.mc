; G1 find_pub under hsim's jump clock: one window a month, so half a year is six days lived.
; One man who knows only his own house gets thirsty; the corpus has to take him from
; want_drink through the find-building survey into a pub and through DRINK. The startup func
; builds the town and the man, the validate func reads what happened - nothing here behaves.

(define-list config
  seeds 4242 4243 4244 4245
  start 1700-01-01
  end 1700-06-30
  clock jump
  mwo "Merlin/bin/demo_tech_level_v2.mwo"
  startup g01-find-pub-startup)

(define-list gauntlet validate g01-find-pub-validate)

(define-func g01-find-pub-startup ()
  (seed_property)
  (head (env-entities [k building residential-building])): ?home
  (make-human ?home [k lower] [k male]): ?man
  (cast seeker ?man)
  (initialize-minds))

(define-func g01-find-pub-validate ()
  (cast seeker): ?man
  (expect (> (acts ?man DRINK succ) 0) "g01: never drank")
  (expect (> (acts ?man find-building succ) 0) "g01: never found a pub")
  (expect (in-mind ?man (find-building-found [k building pub])) "g01: knows no pub")
  (expect (in-mind ?man (any {@self DRINK /succ})) "g01: no memory of a drink"))
