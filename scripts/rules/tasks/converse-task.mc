; ----------------------------------------------------------------------------
; converse ?partner ?agenda - THE exchange: @self talks with ?partner and waits for his
; answers. The conversational behaviour lives here and nowhere else: he faces ?partner,
; stands with him and answers what he asks. Every line is said through tell. Whoever opened
; it goes to ?partner; the man hailed stays where he stands and turns to him.
;
; Running, @self takes part: his public (conversing ..) names ?partner (funcs/conversation.mc),
; and however it ends, the conversation ends for both. It is over when his entry no longer
; names ?partner: a success once ?partner had taken part, a failure when he never did.
;
; With an ?agenda, @self opened it: he goes to stand before ?partner and hails him there, and
; once ?partner has taken him up he
; says the agenda, waits for an answer when it asks something, and takes his leave.
; Without one, @self is the man hailed, and he took it up (thinks/hot/answer-hail-think.mc).
; Its first phase is the answer the hail's opening calls for ("Yes?" to the player's); only
; then does he turn to ?partner and keep company. Should something keener come up before he
; has answered, he ends it, and declines the hail instead. Either way he answers what
; ?partner has asked since it began - "I don't know" when he does not know, and a refusal when
; the answer is closer than he holds ?partner (withholds). The opener cannot
; reach ?partner: it fails.
;
; The rungs run together by design: going, turning and standing hold the legs and head
; while the lines take the mouth, one tell at a time.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; (keeping-company ?partner ?agenda ?converse) - @self is with ?partner in ?converse: the opener
; once he stands before him, the man hailed once he has answered.
(define-func keeping-company (?partner ?agenda ?converse)
  (if (substantial ?agenda)
      (then (standing-before ?partner))
      (else (bb-any ?converse answered))))

(task {@self converse ?partner ?agenda}:?converse
  (tar @excl [k human] @object)
  (aux ?)
  (lint-waive try-rungs-not-exclusive)
  (init
    (check (is-a ?partner [k human]))
    (bb-public-write @self conversing ?partner))
  (cease (end-conversation ?partner))
  (and
    ; The contract: ?partner taking part, and its end.
    (try
      (when (conversing-with ?partner @self))
      (effects (bb-write ?converse partnered @true)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (not (conversing-with @self ?partner)) (bb-any ?converse partnered)))
      (effects (set-outcome ?converse /succ)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (not (conversing-with @self ?partner)) (bb-none ?converse partnered)))
      (effects (set-outcome ?converse /fail)))

    ; Answering the hail - only a man ?partner hailed has one to answer: the response its
    ; opening calls for, before anything else; once it is said, the conversation is under way
    ; (answered).
    (sequence
      (role @self {?partner SAY (formulaic ? opening ?greeting) @self /past}
        (stage
          (when (would-engage ?partner))
          (effects (maintain-proposal {@self tell (formulaic [] response ?greeting) ?partner})))
        (stage
          (effects (bb-write ?converse answered @true)))))

    ; Something keener came up before he answered: he will not take it up after all.
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial ?agenda)
                 (bb-none ?converse answered)
                 (not (would-engage ?partner))))
      (effects (end-conversation ?partner)))

    ; Keeping company: the opener on his way to stand before him, then facing him and listening.
    ; Each step is its own rung, since a rung's effects run once and only its (when) is re-checked.
    (try
      (when (substantial ?agenda)
            (not (standing-before ?partner)))
      (effects (maintain-proposal {@self go-to ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (keeping-company ?partner ?agenda ?converse))
      (effects (maintain-proposal {@self LOOK-AT ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (keeping-company ?partner ?agenda ?converse)
            (not (is-facing @self ?partner)))
      (effects (maintain-proposal {@self TURN-TO ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (keeping-company ?partner ?agenda ?converse)
            (is-facing @self ?partner))
      (effects (maintain-proposal {@self CHAT ?partner})))

    (try
      (when {@self go-to ?partner /fail /caused_by ?converse})
      (effects (end-conversation ?partner)))

    ; Opening it: the hail, once he stands before him.
    (try
      (when (and (substantial ?agenda)
                 (standing-before ?partner)
                 (not (conversing-with ?partner @self))
                 -{@self tell (formulaic ? opening ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic [] opening greeting) ?partner})))

    ; Taken up: the agenda, then his leave once it is answered.
    (try
      (when (and (substantial ?agenda)
                 (conversing-with ?partner @self)
                 -{@self tell ?agenda ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell ?agenda ?partner})))

    (try
      (when (and (substantial ?agenda)
                 (agenda-answered ?partner ?agenda ?converse)
                 -{@self tell (formulaic ? leave_taking ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?partner})))

    (try
      (when {@self tell (formulaic ? leave_taking ?) ?partner /succ /caused_by ?converse})
      (effects (end-conversation ?partner)))

    (try
      (lock)
      (role @self {?partner SAY (qs ? ? ?..):?qs @self /past}:?asked
                  -{@self tell ? ?partner /succ /caused_by ?asked}
        (when (happened-since ?asked ?converse))
        (effects
          (if (withholds ?qs ?partner)
              (then (maintain-proposal {@self tell (formulaic [] refusal answer) ?partner} /caused_by ?asked))
              (else
                (bind (eval-msg /output_unknown_on_fail ?qs ?partner) ?answer)
                (maintain-proposal {@self tell (utterable-msg [] ?answer) ?partner} /caused_by ?asked))))))))