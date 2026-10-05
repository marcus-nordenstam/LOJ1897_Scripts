; ----------------------------------------------------------------------------
; answer-hail (thinks). A hail - a (formulaic opening ..) said to @self - is ALWAYS answered,
; and how is @self's choice: engage, decline or rebuff (funcs/conversation.mc).
;
; The choice is made on the spot and stays open until he begins to say it: each answer rule
; holds while its condition does, so a man who would have engaged but finds something keener
; to do declines instead. Once begun, his answer is the one said (saying-yes / saying-no), and
; it is said at (unbeatable-utility ..), above everything he has going, so nothing can
; silence it. Each holds until he has finished saying something to ?speaker since the hail
; (hail-answered). Taken up, the conversation follows once the yes is said, at what talking
; with ?speaker is worth to him (converse-after-yes).
; ----------------------------------------------------------------------------

(include "../../../macros/tunables.mc")

; Rebuffing a man he despises: a retort, heard as the insult it is.
(think rebuff-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (when (and (hail-open ?heard ?speaker) (rebuffs ?speaker)))
    (bind (unbeatable-utility {@self tell (formulaic rebuff (msg-class insult)) ?speaker} ?heard) ?say)
    (declare-utility (utility-band ?say) (utility-value ?say))
    (effects
      (maintain-proposal {@self tell (formulaic rebuff (msg-class insult)) ?speaker} /caused_by ?heard))))

; Taking it up: a greeting back, while talking with him beats everything else he has going.
(think engage-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (when (and (hail-open ?heard ?speaker)
               (not (rebuffs ?speaker))
               (or (saying-yes ?heard ?speaker)
                   (and (not (saying-no ?heard ?speaker)) (would-engage ?heard ?speaker)))))
    (bind (nth 2 ?heard.target) ?greeting)
    (bind (unbeatable-utility {@self tell (formulaic response ?greeting) ?speaker} ?heard) ?say)
    (declare-utility (utility-band ?say) (utility-value ?say))
    (effects
      (bb-public-maintain @self conversing ?speaker (conversing_ttl_cycles))
      (maintain-proposal {@self tell (formulaic response ?greeting) ?speaker} /caused_by ?heard))))

; Declining for what he would rather be doing.
(think decline-hail
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
    (when (and (hail-open ?heard ?speaker)
               (not (rebuffs ?speaker))
               (or (saying-no ?heard ?speaker)
                   (and (not (saying-yes ?heard ?speaker)) (not (would-engage ?heard ?speaker))))))
    (bind (unbeatable-utility {@self tell (formulaic refusal busy) ?speaker} ?heard) ?say)
    (declare-utility (utility-band ?say) (utility-value ?say))
    (effects
      (maintain-proposal {@self tell (formulaic refusal busy) ?speaker} /caused_by ?heard))))

; He said yes: now he keeps his word, at what talking with ?speaker is worth to him. Once per
; hail - the goal outlives this rule, and the next hail is a record of its own.
(think converse-after-yes
  (role ?speaker {?speaker SAY ? @self /past}
                 {?speaker SAY (formulaic opening ?) @self /past}:?heard
                 {@self tell (formulaic response ?) ?speaker /succ /caused_by ?heard}
                 (bb-none ?heard conversed)
    (bind (hail-worth ?speaker) ?worth)
    (declare-utility (utility-band ?worth) (utility-value ?worth))
    (effects
      (bb-write ?heard conversed @true)
      (bb-public-maintain @self conversing ?speaker (conversing_ttl_cycles))
      (if -{@self goal {@self converse ?speaker}}
          (then (begin-goal {@self converse ?speaker}))))))
