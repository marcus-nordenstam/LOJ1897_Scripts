; c09 crowd - in each of two homes far apart, four men and one woman under one roof, the house's
; supper hour known to her and unknown to the men. The first home is presented (the bubble forms
; round the first man): every man hails her to ask it, in the same minute. Men may speak at once,
; but never two to her at once: whoever would speak to her while another is waits until that line
; is said, and the rest hear her answer the first she talks with. The second home is not presented: there is no hail, each man asks her straight out, one
; line at a time. In both, the men end knowing the supper hour. Seeds state only; the validate func
; reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented first
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
  (conversation-far-home ?home): ?far-home
  (make-human ?far-home [k lower] [k male]): ?first-u
  (cast first-u ?first-u)
  (make-human ?far-home [k lower] [k male]): ?second-u
  (cast second-u ?second-u)
  (make-human ?far-home [k lower] [k male]): ?third-u
  (cast third-u ?third-u)
  (make-human ?far-home [k lower] [k male]): ?fourth-u
  (cast fourth-u ?fourth-u)
  (make-human ?far-home [k lower] [k female]): ?cook-u
  (cast cook-u ?cook-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (conversation-knows-mealtimes ?cook ?home)
  (conversation-knows-mealtimes ?cook-u ?far-home))

; (c09-all-know ?a ?b ?c ?d) - all four men know the supper hour.
(define-func c09-all-know (?a ?b ?c ?d)
  (and (in-mind ?a (knows-supper-hour)) (in-mind ?b (knows-supper-hour))
       (in-mind ?c (knows-supper-hour)) (in-mind ?d (knows-supper-hour))))

(define-func c09-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast third): ?third
  (cast fourth): ?fourth
  (cast cook): ?cook
  (cast first-u): ?first-u
  (cast second-u): ?second-u
  (cast third-u): ?third-u
  (cast fourth-u): ?fourth-u
  (cast cook-u): ?cook-u
  (expect (in-mind ?first (presented-lod)) "c09: the presented first man is not presented")
  (expect (in-mind ?first-u (unpresented-lod)) "c09: the far first man is presented")
  ; The presented crowd: the hails, and never two speaking to her at once.
  (expect (> (+ (acts ?first hail started) (acts ?second hail started) (acts ?third hail started)
                (acts ?fourth hail started))
             2)
          "c09: fewer than three men hailed her")
  (expect (> (+ (flip (in-mind ?cook (talked-with ?first)) 1 0) (flip (in-mind ?cook (talked-with ?second)) 1 0)
                (flip (in-mind ?cook (talked-with ?third)) 1 0) (flip (in-mind ?cook (talked-with ?fourth)) 1 0))
             0)
          "c09: she talked with no man")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c09: two men spoke to her at once")
  (expect (c09-all-know ?first ?second ?third ?fourth) "c09: a man does not know the supper hour")
  ; The unpresented crowd: no hails, one line at a time, the same knowledge.
  (expect (= (+ (acts ?first-u hail started) (acts ?second-u hail started) (acts ?third-u hail started)
                (acts ?fourth-u hail started) (acts ?cook-u hail started))
             0)
          "c09: the far crowd hailed - there is no hailing unpresented")
  (expect (in-mind ?cook-u (= (spoken-over) 0)) "c09: two far men spoke to her at once")
  (expect (c09-all-know ?first-u ?second-u ?third-u ?fourth-u) "c09: a far man does not know the supper hour"))
