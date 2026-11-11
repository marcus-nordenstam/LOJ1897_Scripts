; c01 pair - in each of two homes far apart, a husband and wife under one roof, the house's supper
; hour unknown to him. The first home is presented (the bubble forms round the opener): one hails the
; other - whichever hail lands first is taken up - he asks and she answers, and once neither has
; anything left to say one of them takes his leave and the other, left alone, leaves too. ONE
; conversation: each holds his own talk, both in it, with a venue that opens and closes; when it is
; over its participant set is empty. The second home is not presented: there is no hail and no talk,
; he asks her straight out. In both, the two end knowing the supper hour. Seeds state only; the
; validate func reads.

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented opener
  level "Theatres/demo_tech_level_v2.grs"
  startup c01-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c01-validate deadline 3
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
  (conversation-far-home ?home): ?far-home
  (make-human ?far-home [k lower] [k male]): ?opener-u
  (cast opener-u ?opener-u)
  (make-human ?far-home [k lower] [k female]): ?hailed-u
  (cast hailed-u ?hailed-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (conversation-wed ?opener ?hailed)
  (conversation-wed ?opener-u ?hailed-u)
  (found-household ?hailed)
  (found-household ?hailed-u))

(define-func c01-validate ()
  (cast opener): ?opener
  (cast hailed): ?hailed
  (cast opener-u): ?opener-u
  (cast hailed-u): ?hailed-u
  (expect (in-mind ?opener (presented-lod)) "c01: the presented opener is not presented")
  (expect (in-mind ?opener-u (unpresented-lod)) "c01: the far opener is presented")
  ; The presented pair: the talk's protocol, then what they came to know.
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
  (expect (unsubstantial (conversation-of ?hailed)) "c01: she is still in a conversation")
  (expect (in-mind ?opener (knows-supper-hour)) "c01: he does not know the supper hour")
  (expect (in-mind ?hailed (knows-supper-hour)) "c01: she does not know the supper hour")
  ; The unpresented pair: no protocol, the same knowledge.
  (expect (= (+ (acts ?opener-u hail started) (acts ?hailed-u hail started)) 0) "c01: the far pair hailed - there is no hailing unpresented")
  (expect (in-mind ?opener-u (knows-supper-hour)) "c01: the far husband does not know the supper hour")
  (expect (in-mind ?hailed-u (knows-supper-hour)) "c01: the far wife does not know the supper hour"))
