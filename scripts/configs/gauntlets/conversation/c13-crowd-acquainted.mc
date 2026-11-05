; c13 crowd getting acquainted - eighteen under one roof who know one another only by name, every one
; of them wanting to get acquainted: each would hail the one most worth his while, many of them the
; same one, in the same minute. One man's hail stands on another at a time and the rest wait their
; turn (sync, tasks/hail-task.mc), so nobody is hailed by a crowd (audit-hailed-by-many) and no answer
; rule is cast once per caller past what a crowd can hold; and the hails are answered. Seeds state
; only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c13-startup)

; The household is primed - everyone under the roof knows the others by name and that they live
; there - and everything that would take the cast out of the house or busy them elsewhere is
; inhibited: what is judged is a crowd getting acquainted.
(define-list gauntlet validate c13-validate deadline 20
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver)

(define-macro k-c13-crowd () 18)

(define-func c13-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (bind 0 ?c13-i)
  (repeat (k-c13-crowd)
    (make-human ?home [k lower] (flip (eq (modulo ?c13-i 2) 0) [k male] [k female]))
    (bind (+ ?c13-i 1) ?c13-i))
  (initialize-minds)
  (conversation-household ?home))

; (c13-took-in-count ?home) - how many callers anyone under ?home's roof took in.
(define-func c13-took-in-count (?home)
  (bind 0 ?c13-took)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then
          (for-each ?c13-b (env-entities [k human])
            (if (and (neq ?c13-a ?c13-b) (spatial ?c13-b unit ?home /env) (in-mind ?c13-a (took-in ?c13-b)))
                (then (bind (+ ?c13-took 1) ?c13-took)))))))
  ?c13-took)

; (c13-hails-started ?home) - how many hails anyone under ?home's roof began.
(define-func c13-hails-started (?home)
  (bind 0 ?c13-hails)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then (bind (+ ?c13-hails (acts ?c13-a hail started)) ?c13-hails))))
  ?c13-hails)

(define-func c13-validate ()
  (conversation-first-home): ?home
  (expect (> (c13-hails-started ?home) (k-c13-crowd)) "c13: fewer hails were begun than the crowd is many - no crowd got acquainted")
  (expect (> (c13-took-in-count ?home) (/ (k-c13-crowd) 2)) "c13: fewer than half the crowd's callers were taken in"))
