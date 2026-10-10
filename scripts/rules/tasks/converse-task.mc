; ----------------------------------------------------------------------------
; converse ?partner ?agenda - THE exchange, in a conversation already open both ways: each
; party's (conversing ..) names the other (funcs/conversation.mc). Opening it is hail
; (tasks/hail-task.mc), taking it up is take-up (tasks/take-up-task.mc), and the driver that
; wants the exchange proposes whichever its conversation still lacks.
;
; @self faces ?partner, stands with him and answers what he asks: "I don't know" when he does
; not know, and a refusal when the answer is closer than he holds ?partner (withholds). With an
; ?agenda he says it, waits for the answer when it asks something, and takes his leave
; (tasks/take-leave-task.mc). Every line is said through tell. It is over, a success, when his
; own entry no longer names ?partner - whoever ended it.
;
; The rungs run together by design: turning and looking hold the head while the lines take
; the mouth, one tell at a time.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self converse ?partner ?agenda}:?converse
  (tar @excl [k human] @object)
  (aux ?)
  (lint-waive try-rungs-not-exclusive)
  (init
    (check (is-a ?partner [k human])))
  (and
    (try
      (lint-waive cacheable-read-in-when)
      (when (not (conversing-with @self ?partner)))
      (effects (set-outcome ?converse /succ)))

    (try
      (lint-waive cacheable-read-in-when)
      (when (conversing-with @self ?partner))
      (effects (maintain-proposal {@self LOOK-AT ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (conversing-with @self ?partner)
            (not (is-facing @self ?partner)))
      (effects (maintain-proposal {@self TURN-TO ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (conversing-with @self ?partner)
            (is-facing @self ?partner))
      (effects (maintain-proposal {@self CHAT ?partner})))

    (try
      (when (and (substantial ?agenda)
                 -{@self tell ?agenda ?partner /past /caused_by ?converse}))
      (effects (maintain-proposal {@self tell ?agenda ?partner})))
    (try
      (when (and (substantial ?agenda)
                 (agenda-answered ?partner ?agenda ?converse)))
      (effects (maintain-proposal {@self take-leave ?partner})))

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
