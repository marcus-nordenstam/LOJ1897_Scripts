; c01 pair - a husband and wife under one roof, the house's supper hour unknown: one hails the
; other - whichever hail lands first is taken up - he asks and she answers, and once neither has
; anything left to say one of them takes his leave and the other, left alone, leaves too. ONE
; conversation: each holds his own talk, both in it, with a venue that opens and closes; when it is
; over its participant set is empty. Seeds state only; the validate func reads.

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c01-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c01-validate deadline 15
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

(include "conversation.mc")

(define-func c01-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?opener
  (cast opener ?opener)
  (make-human ?home [k lower] [k female]): ?hailed
  (cast hailed ?hailed)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-wed ?opener ?hailed))

(define-func c01-validate ()
  (cast opener): ?opener
  (cast hailed): ?hailed
  (expect (> (+ (acts ?opener hail succ) (acts ?hailed hail succ)) 0) "c01: no hail was ever taken up")
  (expect (> (+ (acts ?opener take-up succ) (acts ?hailed take-up succ)) 0) "c01: neither took the other up")
  (expect (in-mind ?opener (substantial (any {? participant @self /ever}))) "c01: his exchange never began")
  (expect (in-mind ?opener (unsubstantial (any {? participant @self}))) "c01: his exchange never ended")
  (expect (>= (acts ?hailed tell succ) 2) "c01: she never answered him")
  (expect (or (left-talk ?opener) (left-talk ?hailed)) "c01: neither took their leave")
  (expect (in-mind ?opener (substantial (any {? participant @self /ever}))) "c01: he knows no talk he was in")
  (expect (in-mind ?hailed (substantial (any {? participant @self /ever}))) "c01: she knows no talk she was in")
  (expect (in-mind ?opener (substantial (any {? participant ? /past}))) "c01: his part in the talk never ended")
  (expect (in-mind ?hailed (substantial (any {? participant ? /past}))) "c01: her part in the talk never ended")
  (expect (in-mind ?opener (substantial (any {? venue ? /past}))) "c01: the talk's venue never closed")
  (expect (unsubstantial (conversation-of ?opener)) "c01: he is still in a conversation")
  (expect (unsubstantial (conversation-of ?hailed)) "c01: she is still in a conversation"))
