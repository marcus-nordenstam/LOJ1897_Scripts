; c12 flirt - in each of two homes far apart, a man, a woman and a lodger under one roof, the man and
; the woman unmarried. He fancies her and counts her a friend; she does not count him one. The first
; home is presented (the bubble forms round its suitor): he seeks her company, pays her his
; compliment in that talk, and she answers it as her motives choose. The second is not: there is no
; talk, and he pays it to her straight out, once a day. In both, his flirt tells her - and the
; lodger, when he sees it - that he likely fancies her. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented suitor
  level "Theatres/demo_tech_level_v2.grs"
  startup c12-startup)

; The households are primed - everyone under a roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the courtship.
(define-list gauntlet validate c12-validate deadline 15
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

; (c12-court ?suitor ?beloved) - ?suitor counts ?beloved a friend and fancies her.
(define-func c12-court (?suitor ?beloved)
  (enter-mind ?suitor)
  (observe ?beloved): ?c12-beloved
  (begin-belief {@self friend ?c12-beloved})
  (feel-stance ?c12-beloved attraction 2.5)
  (exit-mind))

(define-func c12-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (conversation-far-home ?home): ?far-home
  (make-human ?home [k lower] [k male]): ?suitor
  (cast suitor ?suitor)
  (make-human ?home [k lower] [k female]): ?beloved
  (cast beloved ?beloved)
  (make-human ?home [k lower] [k male]): ?lodger
  (cast lodger ?lodger)
  (make-human ?far-home [k lower] [k male]): ?suitor-u
  (cast suitor-u ?suitor-u)
  (make-human ?far-home [k lower] [k female]): ?beloved-u
  (cast beloved-u ?beloved-u)
  (make-human ?far-home [k lower] [k male]): ?lodger-u
  (cast lodger-u ?lodger-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (c12-court ?suitor ?beloved)
  (c12-court ?suitor-u ?beloved-u))

; (c12-takes-to-fancy ?suitor ?beloved) - in a mind: it saw ?suitor flirt with ?beloved and so takes
; him to likely fancy her.
(define-func c12-takes-to-fancy (?suitor ?beloved)
  (and (substantial (any {?suitor flirt ?beloved /ever}))
       (substantial (any {?suitor fancy ?beloved /likely}))))

; (c12-saw-flirt ?suitor ?beloved) - in a mind: it saw ?suitor flirt with ?beloved.
(define-func c12-saw-flirt (?suitor ?beloved)
  (substantial (any {?suitor flirt ?beloved /ever})))

(define-func c12-validate ()
  (cast suitor): ?suitor
  (cast beloved): ?beloved
  (cast lodger): ?lodger
  (cast suitor-u): ?suitor-u
  (cast beloved-u): ?beloved-u
  (cast lodger-u): ?lodger-u
  (expect (in-mind ?suitor (presented-lod)) "c12: the presented suitor is not presented")
  (expect (in-mind ?suitor-u (unpresented-lod)) "c12: the far suitor is presented")
  ; The presented courtship: its decorum, then what she came to know.
  (expect (> (acts ?suitor hail started) 0) "c12: he never sought her company")
  (expect (in-mind ?suitor (substantial (any {@self fancy|desire|crave ?}))) "c12: he does not fancy her")
  (expect (> (acts ?suitor flirt started) 0) "c12: he never flirted")
  (expect (in-mind ?beloved (answered-flirt ?suitor)) "c12: she never answered his flirt")
  (expect (unsubstantial (conversation-of ?suitor)) "c12: he is still in a conversation")
  (expect (unsubstantial (conversation-of ?beloved)) "c12: she is still in a conversation")
  (expect (in-mind ?beloved (c12-takes-to-fancy ?suitor ?beloved)) "c12: she does not take him to fancy her")
  (expect (or (not (in-mind ?lodger (c12-saw-flirt ?suitor ?beloved))) (in-mind ?lodger (c12-takes-to-fancy ?suitor ?beloved)))
          "c12: the lodger saw him flirt and does not take him to fancy her")
  ; The unpresented courtship: no decorum, the same knowledge.
  (expect (= (acts ?suitor-u hail started) 0) "c12: the far suitor hailed - there is no hailing unpresented")
  (expect (> (acts ?suitor-u flirt started) 0) "c12: the far suitor never flirted")
  (expect (in-mind ?beloved-u (answered-flirt ?suitor-u)) "c12: the far woman never answered his flirt")
  (expect (in-mind ?beloved-u (c12-takes-to-fancy ?suitor-u ?beloved-u)) "c12: the far woman does not take him to fancy her")
  (expect (or (not (in-mind ?lodger-u (c12-saw-flirt ?suitor-u ?beloved-u))) (in-mind ?lodger-u (c12-takes-to-fancy ?suitor-u ?beloved-u)))
          "c12: the far lodger saw him flirt and does not take him to fancy her"))
