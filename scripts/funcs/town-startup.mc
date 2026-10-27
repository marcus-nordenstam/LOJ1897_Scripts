; The historical town's startup func: the founders, the property seed, the minds' creation
; pass, then the founder generation's marriages and heads. Named by every configs/historical*.mc.

(define-func town-startup ()
  (make-human-founder)
  (seed_property)
  (initialize-minds)
  (wed-founders)
  (seat-founding-heads)
  (found-households)
  (join-parishes))

; The town on the real clock: the same town, and the first founder cast as the `player` the
; world is presented round (historical_1yr_real.mc's `presented player`).
(define-func town-real-startup ()
  (town-startup)
  (cast player (head (env-entities [k human]))))
