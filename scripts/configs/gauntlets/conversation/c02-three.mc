; c02 three - two men and one woman under one roof, the house's supper hour unknown: each man
; hails her to ask it. The hails come at once, each opening a talk of its own; she takes one
; up, and the other man follows her into that talk, or is declined and hails again into it, so
; one talk holds three. Every mind knows the other two as parties of its own copy of the one
; talk. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c02-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c02-validate deadline 15
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

(define-func c02-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k male]): ?second
  (cast second ?second)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (initialize-minds)
  (conversation-household ?home))

(define-func c02-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast cook): ?cook
  (expect (and (or (> (acts ?first hail succ) 0) (> (acts ?first take-up succ) 0))
               (or (> (acts ?second hail succ) 0) (> (acts ?second take-up succ) 0)))
          "c02: a man never came into a talk by a hail, his own or hers")
  (expect (or (> (acts ?cook take-up succ) 0)
              (in-mind ?first (substantial (any {@self take-up ?cook /succ /ever})))
              (in-mind ?second (substantial (any {@self take-up ?cook /succ /ever}))))
          "c02: no hail between her and a man was taken up")
  (expect (in-mind ?cook (knows-talk-with ?first ?second)) "c02: she does not know three in one talk")
  (expect (in-mind ?first (substantial (any {? participant ? /ever}))) "c02: the first knows no talk")
  (expect (in-mind ?second (substantial (any {? participant ? /ever}))) "c02: the second knows no talk")
  (expect (unsubstantial (conversation-of ?cook)) "c02: she is still in a conversation")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c02: two men spoke to her at once"))
