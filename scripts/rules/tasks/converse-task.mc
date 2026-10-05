; ----------------------------------------------------------------------------
; converse ?partner ?agenda - THE exchange: @self talks with ?partner and waits for his
; answers. The conversational behaviour lives here and nowhere else: he goes to ?partner,
; turns to face him, stands with him and answers what he asks. Every line is said through
; tell.
;
; Running, @self takes part: his public (conversing ..) names ?partner (funcs/conversation.mc),
; and however it ends, the conversation ends for both. It is over when his entry no longer
; names ?partner: a success once ?partner had taken part, a failure when he never did.
;
; With an ?agenda, @self opened it: he hails ?partner, and once ?partner has taken him up he
; says the agenda, waits for an answer when it asks something, and takes his leave.
; Without one, @self is the man hailed, and he took it up (thinks/hot/answer-hail-think.mc).
; Its first phase is the answer the hail's opening calls for ("Yes?" to the player's); only
; then does he come to ?partner and keep company. Should something keener come up before he
; has answered, he ends it, and declines the hail instead. Either way he answers what
; ?partner has asked since it began - "I don't know" when he does not know. He cannot reach
; ?partner: it fails.
;
; The rungs run together by design: going, turning and standing hold the legs and head
; while the lines take the mouth, one tell at a time.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

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
      (role @self {?partner SAY (formulaic opening ?greeting) @self /past}
        (stage
          (when (would-engage ?partner))
          (effects (maintain-proposal {@self tell (formulaic response ?greeting) ?partner})))
        (stage
          (effects (bb-write ?converse answered @true)))))

    ; Something keener came up before he answered: he will not take it up after all.
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial ?agenda)
                 (bb-none ?converse answered)
                 (not (would-engage ?partner))))
      (effects (end-conversation ?partner)))

    ; Keeping company: on his way to stand before him, then facing him and listening. Each step
    ; is its own rung, since a rung's effects run once and only its (when) is re-checked.
    (try
      (lint-waive cacheable-read-in-when)
      (when (or (substantial ?agenda) (bb-any ?converse answered))
            (not (standing-before ?partner)))
      (effects (maintain-proposal {@self go ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (or (substantial ?agenda) (bb-any ?converse answered))
            (standing-before ?partner))
      (effects (maintain-proposal {@self LOOK-AT ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (or (substantial ?agenda) (bb-any ?converse answered))
            (standing-before ?partner)
            (not (is-facing @self ?partner)))
      (effects (maintain-proposal {@self TURN-TO ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (or (substantial ?agenda) (bb-any ?converse answered))
            (standing-before ?partner)
            (is-facing @self ?partner))
      (effects (maintain-proposal {@self CHAT ?partner})))

    (try
      (when {@self go ?partner /fail /caused_by ?converse})
      (effects (end-conversation ?partner)))

    ; Opening it: the hail.
    (try
      (when (and (substantial ?agenda)
                 (not (conversing-with ?partner @self))
                 -{@self tell (formulaic opening ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic opening greeting) ?partner})))

    ; Taken up: the agenda, then his leave once it is answered.
    (try
      (when (and (substantial ?agenda)
                 (conversing-with ?partner @self)
                 -{@self tell ?agenda ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell ?agenda ?partner})))

    (try
      (when (and (substantial ?agenda)
                 (agenda-answered ?partner ?agenda ?converse)
                 -{@self tell (formulaic leave_taking ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic leave_taking bye) ?partner})))

    (try
      (when {@self tell (formulaic leave_taking ?) ?partner /succ /caused_by ?converse})
      (effects (end-conversation ?partner)))

    (try
      (role ?asked (every {?partner SAY ? @self /past})
                   (is-qs ?asked.target)
                   -{@self tell ? ?partner /past /caused_by ?asked}
        (when (happened-since ?asked ?converse))
        (effects
          (bind (eval-msg /output_unknown_on_fail ?asked.target ?partner) ?answer)
          (maintain-proposal {@self tell (utterable-msg ?answer) ?partner} /caused_by ?asked))))))
