; The historical town's startup func: the founders, the property seed, the minds' creation
; pass, then the (startup) agenda. Named by every configs/historical*.mc.

(define-func town-startup ()
  (make-human-founder)
  (seed_property)
  (initialize-minds)
  (run-startup-rules))
