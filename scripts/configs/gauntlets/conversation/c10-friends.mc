; c10 friends - two friends under one roof, each with news of her own the other has not heard. In
; the same room, one seeks the other's company: a hail, a conversation, and in it each tells her
; news and asks the other's, one line at a time, until neither has anything left to say - then
; they part. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c10-startup)

(define-list gauntlet validate c10-validate)

(define-func c10-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k female]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k female]): ?second
  (cast second ?second)
  (initialize-minds)
  (conversation-befriend ?first ?second))

(define-func c10-validate ()
  (cast first): ?first
  (cast second): ?second
  (expect (> (+ (acts ?first hail succ) (acts ?second hail succ)) 0) "c10: neither sought the other's company")
  (expect (> (acts ?first converse started) 0) "c10: the first never held a conversation")
  (expect (> (acts ?second converse started) 0) "c10: the second never held a conversation")
  (expect (>= (acts ?first tell succ) 3) "c10: the first said fewer than three things")
  (expect (>= (acts ?second tell succ) 3) "c10: the second said fewer than three things")
  (expect (in-mind ?first (asked-whats-new ?second)) "c10: the first never asked the second's news, or had no answer")
  (expect (in-mind ?second (asked-whats-new ?first)) "c10: the second never asked the first's news, or had no answer")
  (expect (> (acts ?first take-leave succ) 0) "c10: the first never took her leave")
  (expect (in-mind ?first (= (spoken-over) 0)) "c10: two spoke to the first at once")
  (expect (in-mind ?second (= (spoken-over) 0)) "c10: two spoke to the second at once")
  (expect (unsubstantial (bb-public-read ?first conversing)) "c10: the first is still in a conversation")
  (expect (unsubstantial (bb-public-read ?second conversing)) "c10: the second is still in a conversation")
  (expect (unsubstantial (bb-public-read ?first has-more)) "c10: the first still shows she has more to say")
  (expect (unsubstantial (bb-public-read ?second has-more)) "c10: the second still shows she has more to say"))
