; c12 flirt - a man and a woman under one roof, unmarried. He fancies her and counts her a friend;
; she does not count him one. He seeks her company with his news, and in that talk pays her his
; compliment; she answers it as her motives choose. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c12-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c12-validate deadline 15
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

(define-func c12-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?suitor
  (cast suitor ?suitor)
  (make-human ?home [k lower] [k female]): ?beloved
  (cast beloved ?beloved)
  (initialize-minds)
  (conversation-household ?home)
  (enter-mind ?suitor)
  (observe ?beloved): ?c12-beloved
  (begin-belief {@self friend ?c12-beloved})
  (feel-stance ?c12-beloved attraction 2.5)
  (exit-mind))

(define-func c12-validate ()
  (cast suitor): ?suitor
  (cast beloved): ?beloved
  (expect (> (acts ?suitor hail started) 0) "c12: he never sought her company")
  (expect (in-mind ?suitor (substantial (any {@self fancy|desire|crave ?}))) "c12: he does not fancy her")
  (expect (> (acts ?suitor flirt started) 0) "c12: he never flirted")
  (expect (in-mind ?beloved (answered-flirt ?suitor)) "c12: she never answered his flirt")
  (expect (unsubstantial (conversation-of ?suitor)) "c12: he is still in a conversation")
  (expect (unsubstantial (conversation-of ?beloved)) "c12: she is still in a conversation"))
