; c02 three - in each of two homes far apart, two men and one woman under one roof, the house's
; supper hour known to her and unknown to the men. The first home is presented (the bubble forms
; round the first man): each man hails her to ask it, at once; she takes one up and answers him in
; that talk, and the other, standing by, hears the answer. The second home is not presented: there
; is no hail and no talk, each man asks her straight out. In both, the men end knowing the supper
; hour and never two speak to her at once. The first man also asks her what she wants her life to
; amount to, which she tells only a friend: she answers that it is none of his business, and he
; takes her to withhold it from him. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented first
  level "Theatres/demo_tech_level_v2.grs"
  startup c02-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c02-validate deadline 3
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
  (conversation-far-home ?home): ?far-home
  (make-human ?far-home [k lower] [k male]): ?first-u
  (cast first-u ?first-u)
  (make-human ?far-home [k lower] [k male]): ?second-u
  (cast second-u ?second-u)
  (make-human ?far-home [k lower] [k female]): ?cook-u
  (cast cook-u ?cook-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (conversation-knows-mealtimes ?cook ?home)
  (conversation-knows-mealtimes ?cook-u ?far-home)
  (conversation-wonder-life-aim ?first ?cook)
  (conversation-wonder-life-aim ?first-u ?cook-u))

(define-func c02-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast cook): ?cook
  (cast first-u): ?first-u
  (cast second-u): ?second-u
  (cast cook-u): ?cook-u
  (expect (in-mind ?first (presented-lod)) "c02: the presented first man is not presented")
  (expect (in-mind ?first-u (unpresented-lod)) "c02: the far first man is presented")
  ; The presented three: a talk she was hailed into, then what the men came to know.
  (expect (or (> (acts ?cook take-up succ) 0)
              (in-mind ?first (substantial (any {@self take-up ?cook /succ /ever})))
              (in-mind ?second (substantial (any {@self take-up ?cook /succ /ever}))))
          "c02: no hail between her and a man was taken up")
  (expect (in-mind ?cook (substantial (any {? participant @self /ever}))) "c02: she knows no talk she was in")
  (expect (unsubstantial (conversation-of ?cook)) "c02: she is still in a conversation")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c02: two men spoke to her at once")
  (expect (in-mind ?first (knows-supper-hour)) "c02: the first does not know the supper hour")
  (expect (in-mind ?second (knows-supper-hour)) "c02: the second does not know the supper hour")
  (expect (in-mind ?first (withheld-from-me ?cook)) "c02: she told him what she tells only a friend, or he never learned she would not")
  ; The unpresented three: no protocol, the same knowledge.
  (expect (= (+ (acts ?first-u hail started) (acts ?second-u hail started) (acts ?cook-u hail started)) 0)
          "c02: the far three hailed - there is no hailing unpresented")
  (expect (in-mind ?cook-u (= (spoken-over) 0)) "c02: two far men spoke to her at once")
  (expect (in-mind ?first-u (knows-supper-hour)) "c02: the far first does not know the supper hour")
  (expect (in-mind ?second-u (knows-supper-hour)) "c02: the far second does not know the supper hour")
  (expect (in-mind ?first-u (withheld-from-me ?cook-u)) "c02: the far cook told him what she tells only a friend, or he never learned she would not"))
