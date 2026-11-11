; c10 friends - in each of two homes far apart, two friends under one roof, each with news of her own
; the other has not heard: she has just got engaged. The first home is presented (the bubble forms round the first friend): in
; the same room, one seeks the other's company: a hail, a conversation, and in it each tells her news
; and asks the other's, one line at a time, until neither has anything left to say - then they part.
; The second is not: there is no hail and no talk, each tells the other straight out. In both, each
; ends holding the other's news. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented first
  level "Theatres/demo_tech_level_v2.grs"
  startup c10-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited, and so is the wedding each engagement would set her
; planning: what is judged is the talk.
(define-list gauntlet validate c10-validate deadline 15
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver
          honour-betrothal)

(define-func c10-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k female]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k female]): ?second
  (cast second ?second)
  (conversation-far-home ?home): ?far-home
  (make-human ?far-home [k lower] [k female]): ?first-u
  (cast first-u ?first-u)
  (make-human ?far-home [k lower] [k female]): ?second-u
  (cast second-u ?second-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (conversation-befriend ?first ?second)
  (conversation-befriend ?first-u ?second-u)
  (conversation-third-home ?home ?far-home): ?third-home
  (conversation-engage ?first ?third-home)
  (conversation-engage ?second ?third-home)
  (conversation-engage ?first-u ?third-home)
  (conversation-engage ?second-u ?third-home))

(define-func c10-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast first-u): ?first-u
  (cast second-u): ?second-u
  (expect (in-mind ?first (presented-lod)) "c10: the presented first friend is not presented")
  (expect (in-mind ?first-u (unpresented-lod)) "c10: the far first friend is presented")
  ; The presented pair: the talk's protocol, then what they came to know.
  (expect (> (+ (acts ?first hail succ) (acts ?second hail succ)) 0) "c10: neither sought the other's company")
  (expect (in-mind ?first (substantial (any {? participant @self /ever}))) "c10: the first never held a conversation")
  (expect (in-mind ?second (substantial (any {? participant @self /ever}))) "c10: the second never held a conversation")
  (expect (>= (acts ?first tell succ) 3) "c10: the first said fewer than three things")
  (expect (>= (acts ?second tell succ) 3) "c10: the second said fewer than three things")
  (expect (in-mind ?first (asked-whats-new ?second)) "c10: the first never asked the second's news, or had no answer")
  (expect (in-mind ?second (asked-whats-new ?first)) "c10: the second never asked the first's news, or had no answer")
  (expect (and (in-mind ?first (responded-to-tidings ?second)) (in-mind ?second (responded-to-tidings ?first)))
          "c10: a friend's tidings went without a response")
  (expect (or (left-talk ?first) (left-talk ?second)) "c10: neither took her leave")
  (expect (in-mind ?first (= (spoken-over) 0)) "c10: two spoke to the first at once")
  (expect (in-mind ?second (= (spoken-over) 0)) "c10: two spoke to the second at once")
  (expect (unsubstantial (conversation-of ?first)) "c10: the first is still in a conversation")
  (expect (unsubstantial (conversation-of ?second)) "c10: the second is still in a conversation")
  (expect (not (has-more-anywhere ?first)) "c10: the first still shows she has more to say")
  (expect (not (has-more-anywhere ?second)) "c10: the second still shows she has more to say")
  (expect (in-mind ?first (holds-engagement-of ?second)) "c10: the first does not hold the second's news")
  (expect (in-mind ?second (holds-engagement-of ?first)) "c10: the second does not hold the first's news")
  ; The unpresented pair: no protocol, the same knowledge.
  (expect (= (+ (acts ?first-u hail started) (acts ?second-u hail started)) 0) "c10: the far pair hailed - there is no hailing unpresented")
  (expect (in-mind ?first-u (holds-engagement-of ?second-u)) "c10: the far first does not hold the far second's news")
  (expect (in-mind ?second-u (holds-engagement-of ?first-u)) "c10: the far second does not hold the far first's news"))
