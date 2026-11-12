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
; the speaker's own. Everyone within its radius hears it on the next perception pass
; (in-earshot); a preroll of 0 makes it audible this instant.
;
; A DIRECTED say stamps the addressee in the act's /aux (the per-listener "told"
; dedup); a BROADCAST leaves it absent. Delivery is by earshot either way - the
; addressee is who it is ADDRESSED to, never who receives it. Which sound it makes is
; (voice-sound ..) (funcs/conversation.mc), the voice the line rides, which tell measures by too.
; ----------------------------------------------------------------------------

(include "../macros/formulaic-macros.mc")

(define-func deliver-speech (?xsay)
  (do
    (create-entity (voice-sound ?xsay.target) (spatial @self bounds /env)): ?sound
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
; The engine calls it once per (utterance, listener), with the listener as @self, and passes
; ?SAY, this listener's own {<speaker> SAY <msg> <audience>} record: its target is the heard
; message (his own mental copy), its subject the speaker (@i) and its auxiliary the audience
; (@you), each as he holds them; @nothing for a broadcast.
; What stays in C++ is the boundary, not the policy: the dead-listener skip and
; the mind-space guard are crash-prevention invariants about the abs/mental
; seam, and the run-profile notes are instrumentation. The adopted beliefs come
; back so the engine can count them for the dropped-utterance detector; @nothing
; says the line carries no fact by design - a question, an "I don't know", a
; formulaic with nothing in it to adopt - and is never counted as dropped.
; ----------------------------------------------------------------------------

(define-func absorb-heard-fact (?fact ?SAY)
  (if (is-belief ?fact)
    (then
      ; HOW this mind came to know it: the utterance, not its own eyes.
      ; Interrogation and the re-tell cascade both read that link.
      (add-source ?fact ?SAY)
      (bind ?fact.subject ?subj)
      ; PEOPLE only. A heard fact can subject a BUILDING - the enclosure deixis
      ; carries household facts about the home - and an acquaintance tie to a
      ; building would put it in a social circle, where death-propagation would
      ; try to enter its mind.
      (if (and (is-a ?subj [k human])
               (neq ?subj @self))
        (then (begin-belief {@self acquaintance ?subj}))))))

; (adopt-authority-introduction ?msg ?speaker ?SAY) - the hearer takes ?speaker to hold a job of
; the kind he introduced himself by: the job he already knows him to hold of that kind, else a
; new one.
(define-func adopt-authority-introduction (?msg ?speaker ?SAY)
  (bind (nth (k-formulaic-office-field) ?msg) ?kind)
  (absorb-heard-fact (begin-belief {?speaker job (o ?kind {?speaker job @o})}) ?SAY))

; (asked-clause ?speaker ?reply) - the fact ?reply answered: the question of the inquire up ?reply's
; causes that @self made of ?speaker - the fact @self wondered about when that caused the asking,
; else the clause the question searched; @nothing when ?reply answered no question of @self's.
(define-func asked-clause (?speaker ?reply)
  (bind @nothing ?answered)
  (bind (caused-by /recurse ?reply {@self inquire ?speaker ? /ever}) ?inquire)
  (if (is-belief ?inquire)
      (then
        (bind ?inquire.auxiliary ?asked-msg)
        (bind (nth (k-msg-first-content-field) ?asked-msg) ?asked-content)
        (bind (nth 1 ?asked-content) ?answered)
        (bind (caused-by ?inquire {@self wonder ?}) ?wonder)
        (if (is-belief ?wonder)
            (then (bind ?wonder.target ?answered)))))
  ?answered)

; (adopt-not-knowing ?speaker ?SAY) - ?speaker answered "I don't know" (?SAY) to a question @self
; inquired of him: the hearer takes him not to know what it asked.
(define-func adopt-not-knowing (?speaker ?SAY)
  (bind (asked-clause ?speaker ?SAY) ?asked)
  (if (is-clause ?asked)
      (then (absorb-heard-fact (begin-belief {?speaker /not know ?asked}) ?SAY))))

; (adopt-withholding ?speaker ?SAY) - ?speaker answered "none of your business" (?SAY) to a
; question @self inquired of him: the hearer takes him to withhold what it asked from @self.
(define-func adopt-withholding (?speaker ?SAY)
  (bind (asked-clause ?speaker ?SAY) ?asked)
  (if (is-clause ?asked)
      (then (absorb-heard-fact (begin-belief {?speaker withhold ?asked @self}) ?SAY))))

; (identity-asked ?speaker ?msg ?SAY) - the ghost @self asked ?speaker which one it is, when ?SAY,
; his reply ?msg, answers that question; @nothing otherwise.
(define-func identity-asked (?speaker ?msg ?SAY)
  (bind @nothing ?ghost)
  (if (matches ?msg (msg /reply ?..))
      (then
        (bind (asked-clause ?speaker ?SAY) ?asked)
        (if (is-object ?asked)
            (then (bind ?asked ?ghost)))))
  ?ghost)

(define-func /hear adopt-heard-msg (?SAY)
  (bind ?SAY.target ?msg)
  (bind ?SAY.subject ?speaker)
  (if (matches ?msg (formulaic ? opening-phrase authority ?..))
      (then (adopt-authority-introduction ?msg ?speaker ?SAY)))
  (if (matches ?msg (msg ? @unknown))
      (then (adopt-not-knowing ?speaker ?SAY)))
  (if (matches ?msg (formulaic ? refusal answer))
      (then (adopt-withholding ?speaker ?SAY)))
  ; A QUESTION is not a claim. The heard {asker SAY (qs ..)} record IS the
  ; deliverable - respond answers it straight off that record - and adopting the
  ; asked pattern would turn a man's question into this listener's belief.
  (if (or (matches ?msg (qs ?..)) (matches ?msg (msg ? @unknown)))
    (then
      ; A question names whom it asks about: the talk notes those @self holds, so a pronoun after
      ; it can mean them.
      (if (matches ?msg (qs ?..))
          (then (record-heard ?SAY (shared-talk ?speaker))))
      @nothing)
    (else
      ; The answer to "which one?" tells the ghost asked about apart - it is read as facts about
      ; him, never as a claim of its own. @fail binds through: an undecodable message is no facts,
      ; not an abort.
      (bind (identity-asked ?speaker ?msg ?SAY) ?ghost)
      (if (is-object ?ghost)
          (then (tolerate (adopt-identity ?SAY ?ghost (shared-talk ?speaker))): ?out)
          (else (tolerate (adopt-msg ?SAY (shared-talk ?speaker))): ?out))
      (if (is-list ?out)
        (then (for-each ?fact ?out (absorb-heard-fact ?fact ?SAY)))
        (else (absorb-heard-fact ?out ?SAY)))
      (flip (and (matches ?msg (formulaic ?..)) (not (is-list ?out)) (not (is-belief ?out))) @nothing ?out))))
