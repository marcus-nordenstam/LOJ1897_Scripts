; c09 crowd - four men and one woman under one roof, the house's supper hour unknown: every man
; hails her to ask it, in the same minute. Men may speak at once, but never two to her at once:
; whoever would speak to her while another is waits until that line is said. Seeds state only;
; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c09-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c09-validate deadline 20
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

(define-func c09-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k male]): ?second
  (cast second ?second)
  (make-human ?home [k lower] [k male]): ?third
  (cast third ?third)
  (make-human ?home [k lower] [k male]): ?fourth
  (cast fourth ?fourth)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (initialize-minds)
  (conversation-household ?home))

(define-func c09-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast third): ?third
  (cast fourth): ?fourth
  (cast cook): ?cook
  (expect (> (+ (acts ?first hail started) (acts ?second hail started) (acts ?third hail started)
                (acts ?fourth hail started))
             2)
          "c09: fewer than three men hailed her")
  (expect (> (+ (flip (in-mind ?cook (talked-with ?first)) 1 0) (flip (in-mind ?cook (talked-with ?second)) 1 0)
                (flip (in-mind ?cook (talked-with ?third)) 1 0) (flip (in-mind ?cook (talked-with ?fourth)) 1 0))
             1)
          "c09: she talked with fewer than two men")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c09: two men spoke to her at once"))
