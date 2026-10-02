; ----------------------------------------------------------------------------
; converse ?partner ?agenda - THE exchange: @self talks with ?partner and waits for his
; answers. The conversational behaviour lives here and nowhere else: he goes to ?partner,
; turns to face him, stands with him and answers what he asks. Every line is said through
; tell.
;
; With an ?agenda, @self opened it: he hails ?partner, and once ?partner has taken him up
; (he posts conversing @self) he says the agenda, waits for an answer when it asks
; something, and takes his leave. A hail answered without being taken up fails it.
; Without one, @self is the man hailed: he took it up (thinks/hot/answer-hail-think.mc) and
; keeps company until ?partner takes his leave - coming to him first, when he was hailed
; from further off. Either way he answers what ?partner has asked since it began - "I don't
; know" when he does not know - and posts conversing ?partner for as long as it runs, which
; the other side and the host read. He cannot reach ?partner: it fails.
;
; The rungs run together by design: going, turning and standing hold the legs and head
; while the lines take the mouth, one tell at a time.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self converse ?partner ?agenda}:?converse
  (tar @excl [k human] @object)
  (aux ?)
  (lint-waive try-rungs-not-exclusive)
  (init (check (is-a ?partner [k human])))
  (and
    ; Keeping company: on his way to stand before him, then facing him and listening. Each step
    ; is its own rung, since a rung's effects run once and only its (when) is re-checked.
    (try
      (effects (bb-public-maintain @self conversing ?partner (conversing_ttl_cycles))))
    (try
      (when (not (standing-before ?partner)))
      (effects (maintain-proposal {@self go ?partner})))
    (try
      (when (standing-before ?partner))
      (effects (maintain-proposal {@self LOOK-AT ?partner})))
    (try
      (when (standing-before ?partner)
            (not (is-facing @self ?partner)))
      (effects (maintain-proposal {@self TURN-TO ?partner})))
    (try
      (when (standing-before ?partner)
            (is-facing @self ?partner))
      (effects (maintain-proposal {@self CHAT ?partner})))

    (try
      (when {@self go ?partner /fail /caused_by ?converse})
      (effects
        (bb-public-clear @self conversing)
        (set-outcome ?converse /fail)))

    ; Opening it: the hail.
    (try
      (when (and (substantial ?agenda)
                 (not (engaged-with ?partner))
                 -{@self tell (formulaic opening ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic opening greeting) ?partner})))

    (try
      (when (and (substantial ?agenda)
                 (hail-turned-down ?partner ?converse)))
      (effects
        (bb-public-clear @self conversing)
        (set-outcome ?converse /fail)))

    ; Taken up: the agenda, then his leave once it is answered.
    (try
      (when (and (substantial ?agenda)
                 (engaged-with ?partner)
                 -{@self tell ?agenda ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell ?agenda ?partner})))

    (try
      (when (and (substantial ?agenda)
                 (agenda-answered ?partner ?agenda ?converse)
                 -{@self tell (formulaic leave_taking ?) ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell (formulaic leave_taking bye) ?partner})))

    (try
      (when {@self tell (formulaic leave_taking ?) ?partner /succ /caused_by ?converse})
      (effects
        (bb-public-clear @self conversing)
        (set-outcome ?converse /succ)))

    ; He took his leave of @self.
    (try
      (when (any-happened-since (every {?partner SAY (formulaic leave_taking ?) @self /past}) ?converse))
      (effects
        (bb-public-clear @self conversing)
        (set-outcome ?converse /succ)))

    (try
      (role ?asked (every {?partner SAY ? @self /past})
                   (is-qs ?asked.target)
                   -{@self tell ? ?partner /past /caused_by ?asked}
        (when (happened-since ?asked (converse-began ?partner ?converse)))
        (effects
          (bind (eval-msg /output_unknown_on_fail ?asked.target ?partner) ?answer)
          (maintain-proposal {@self tell (utterable-msg ?answer) ?partner} /caused_by ?asked))))))
