; ----------------------------------------------------------------------------
; speech.mc - the PHYSICAL half of a speech act, as content.
;
; This was C++ (env/functions/comms_functions.h emit_tell) and had no business
; being there: it hardcoded the SAY label, the [k speech] sound kind and the
; earshot radius. All three are world knowledge, so they live here.
;
; No act-belief is made here. {@self SAY <msg> <audience>} is minted by the action
; pipeline when a SAY proposal wins selection and externalized to the abs mind at
; promotion; SAY.mc's (xaction ?xsay) hands this func that ABS twin. All that is
; left is making it audible: a [k speech] sound entity at the speaker's own bounds
; carrying the twin, so the objective record the world hears can never drift from
; the speaker's own. Co-present NPCs overhear it on the next perception pass; a
; preroll of 0 makes it audible this instant.
;
; A DIRECTED say stamps the addressee in the act's /aux (the per-listener "told"
; dedup); a BROADCAST leaves it absent. Delivery is by co-presence either way -
; the addressee is who it is ADDRESSED to, never who receives it.
; ----------------------------------------------------------------------------

(define-func deliver-speech (?xsay)
  (do
    (create-entity [k speech] (spatial @self bounds)): ?sound
    (set-attr ?sound create-action ?xsay)
    (set-attr ?sound speaker @self)
    (set-attr ?sound preroll 0)))

; ----------------------------------------------------------------------------
; adopt-heard-msg - the LISTENER half of a speech act, as content.
;
; deliver-speech above makes an utterance audible; this decides what a listener
; DOES with one he heard. It was C++ too, and held three pieces of world
; knowledge: that a QUESTION carries no assertable facts, that a heard fact is
; SOURCED from the utterance that carried it rather than from one's own eyes,
; and that hearing about someone makes them an acquaintance.
;
; The engine calls it once per (utterance, listener), with the listener as @self:
;   ?msg      the heard message - this listener's own mental copy
;   ?speaker  who said it                 (@i)
;   ?audience who it was said to          (@you); @nothing for a broadcast
;   ?tell     this listener's mental {?speaker SAY ?msg ?audience} record
; What stays in C++ is the boundary, not the policy: the dead-listener skip and
; the mind-space guard are crash-prevention invariants about the abs/mental
; seam, and the run-profile notes are instrumentation. The adopted beliefs come
; back so the engine can count them for the dropped-utterance detector.
; ----------------------------------------------------------------------------

(define-func absorb-heard-fact (?fact ?tell)
  (if (is-belief ?fact)
    (then
      ; HOW this mind came to know it: the utterance, not its own eyes.
      ; Interrogation and the re-tell cascade both read that link.
      (add-source ?fact ?tell)
      (bind ?fact.subject ?subj)
      ; PEOPLE only. A heard fact can subject a BUILDING - the enclosure deixis
      ; carries household facts about the home - and an acquaintance tie to a
      ; building would put it in a social circle, where death-propagation would
      ; try to enter its mind.
      (if (and (is-a ?subj [k human])
               (neq ?subj @self)
               -{@self acquaintance ?subj})
        (then (begin-belief {@self acquaintance ?subj}))))))

(define-func adopt-heard-msg (?msg ?speaker ?audience ?tell)
  ; A QUESTION is not a claim. The heard {asker SAY (qs ..)} record IS the
  ; deliverable - answer_mealtimes casts a role straight on it - and adopting the
  ; asked pattern would turn a man's question into this listener's belief.
  (if (is-qs ?msg)
    (then @fail)
    (else
      ; @fail binds through: an undecodable message is no facts, not an abort.
      (tolerate (adopt-msg ?msg ?speaker ?audience): ?out)
      (if (is-list ?out)
        (then (for-each ?fact ?out (absorb-heard-fact ?fact ?tell)))
        (else (absorb-heard-fact ?out ?tell)))
      ?out)))
