; ----------------------------------------------------------------------------
; reactions (npc-reflex, react phase) - the category reaction doctrine, ported
; row-for-row from the retired ms1/reactions.ms1 (reaction ..) rows.
;
; POV is WHERE @self SITS in the gate (construal = {actor <category> patient}):
;   {?actor CAT @self}    - patient row (it was done to me)
;   {@self CAT ?patient}  - actor row (I did it)
;   {?actor CAT ?patient} - third-party row (a free var never binds @self on a
;                           react gate, so the three are disjoint)
; Mints ride the construed act as /caused_by; salience is the authored base in
; hours (mood x trait scaling inside the mint ops). Third-party PRESSURE
; salience additionally scales by (mobilisation-scale <patient>) - kin x warmth
; x justice; emotions are never scaled (feeling for a stranger is cheap,
; taking up arms for one is not). The categorize-threshold gate runs in the
; drain before any of these dispatch.
; ----------------------------------------------------------------------------

; -- wrong_act (umbrella: any wronging - accumulates with the specific rows) --
(npc-reflex {?actor wrong_act @self}:?c
  (effects
    (mint-emotion anger ?actor 24)
    (mint-emotion distress @nothing 72)
    (mint-pressure humiliation ?actor 720)
    (mint-pressure injustice ?actor 2160)
    ; A wrong ends a friendship but does NOT fabricate a structural enemy tie:
    ; the durable affective residue is the emotion->stance coupling.
    (end-bond {@self friend ?actor})))

(npc-reflex {@self wrong_act ?patient}:?c
  (effects
    (mint-emotion guilt @self 720)
    (mint-emotion fear @nothing 168)
    (mint-pressure moral_violation @self 2160)
    (mint-pressure exposure_risk ?patient 1440)))

(npc-reflex {?actor wrong_act ?patient}:?c
  (effects
    (mint-emotion distress ?actor 24)
    (mint-emotion fear ?actor 48)
    ; 60 days: survives 2 monthly deliberate cycles so a witness keeps their
    ; grievance long enough to act on it.
    (mint-pressure injustice ?actor (* 1440 (mobilisation-scale ?patient)))))

; -- harm_act (physical / mortal injury) --
(npc-reflex {?actor harm_act @self}:?c
  (effects
    (mint-emotion fear ?actor 168)
    (mint-pressure existential_threat ?actor 2160)))

(npc-reflex {@self harm_act ?patient}:?c
  (effects
    (mint-emotion fear @nothing 168)))

(npc-reflex {?actor harm_act ?patient}:?c
  (effects
    (mint-emotion fear ?actor 48)
    (mint-pressure existential_threat ?actor (* 720 (mobilisation-scale ?patient)))))

; -- appropriation_act (theft / fraud / embezzlement) --
(npc-reflex {?actor appropriation_act @self}:?c
  (effects
    (mint-emotion anger ?actor 168)
    (mint-pressure resource_scarcity @nothing 1440)))

(npc-reflex {@self appropriation_act ?patient}:?c
  (effects
    (mint-pressure exposure_risk ?patient 1440)))

(npc-reflex {?actor appropriation_act ?patient}:?c
  (effects
    (mint-emotion distress ?actor 24)))

; -- suffer_loss_act (patient lost something - theft discovery, ruin). The
; agent slot is the LOST PROP (the culprit is unknown by design), so anger and
; distress are FOCUSLESS and the pressure drives acquisitive deliberation, not
; aggression. No actor or third-party rows.
(npc-reflex {?prop suffer_loss_act @self}:?c
  (effects
    (mint-emotion anger @nothing 72)
    (mint-emotion distress @nothing 168)
    (mint-pressure resource_scarcity @nothing 1440)))

; -- coercion_act (forcible compulsion) --
(npc-reflex {?actor coercion_act @self}:?c
  (effects
    (mint-emotion fear ?actor 168)
    (mint-pressure autonomy_loss ?actor 1440)
    (mint-pressure existential_threat ?actor 720)))

(npc-reflex {@self coercion_act ?patient}:?c
  (effects
    (mint-pressure moral_violation @self 720)))

(npc-reflex {?actor coercion_act ?patient}:?c
  (effects
    (mint-emotion fear ?actor 48)))

; -- threaten_act (menace / extortion / implicit harm) --
(npc-reflex {?actor threaten_act @self}:?c
  (effects
    (mint-emotion fear ?actor 72)
    (mint-pressure existential_threat ?actor 720)))

(npc-reflex {?actor threaten_act ?patient}:?c
  (effects
    (mint-emotion fear ?actor 24)))

; -- slight_act (insult / mock / lesser affront). 2-week humiliation base: a
; SINGLE insult fades before the monthly deliberate sees it, but re-mints ADD
; salience, so repeated insult builds past the action threshold (slow-burn
; grudge, not instant brooding).
(npc-reflex {?actor slight_act @self}:?c
  (effects
    (mint-emotion anger ?actor 8)
    (mint-emotion contempt ?actor 48)
    (mint-pressure humiliation ?actor 336)))

(npc-reflex {@self slight_act ?patient}:?c
  (effects
    (mint-emotion pride @self 24)))

(npc-reflex {?actor slight_act ?patient}:?c
  (effects
    (mint-emotion contempt ?actor 24)))

; -- rivalrous_act (actor positionally outcompetes patient): the loser feels
; the loss; the winner takes the prize, not the emotional payoff. 6-month
; rivalry base: slower than humiliation, faster than injustice.
(npc-reflex {?actor rivalrous_act @self}:?c
  (effects
    (mint-emotion envy ?actor 168)
    (mint-emotion contempt ?actor 48)
    (mint-pressure rivalry_pressure ?actor 4320)))

(npc-reflex {?actor rivalrous_act ?patient}:?c
  (effects
    (mint-emotion envy ?actor 24)))

; -- betray_act (broken trust). Betrayal ends the love + friend bonds (real
; structural changes); the trust collapse rides the emotion->stance coupling.
(npc-reflex {?actor betray_act @self}:?c
  (effects
    (mint-emotion anger ?actor 24)
    (mint-emotion grief @nothing 168)
    (mint-pressure attachment_loss ?actor 2160)
    (end-bond {@self love ?actor})
    (end-bond {@self friend ?actor})))

; The affair supplement: a betrayal whose construed act is a LOVER belief also
; mints contempt at the interloper (the affair's other party) and the
; humiliation the non-lethal recourse rules (affair_fallout) gate on.
; Subsumes the retired appraise-betrayal C++ primitive.
(npc-reflex {?partner betray_act @self}:?c
  (caused-by ?c {? lover ?}):?affair
  (when (substantial ?affair))
  (effects
    (mint-emotion contempt ?affair.target 120)
    (mint-pressure humiliation ?partner 720)))

(npc-reflex {@self betray_act ?patient}:?c
  (effects
    (mint-emotion guilt @self 720)
    (mint-pressure moral_violation @self 1440)
    (mint-pressure exposure_risk ?patient 1440)))

; Sadist substitution (was the /pov third_party_sadist row): above the sadism
; threshold the modal third-party row yields to schadenfreude. A consciously
; kept same-pattern pair (reflex-duplicate-pattern is the sanctioned warning).
(npc-reflex {?actor betray_act ?patient}:?c
  (when (<= (attr @self sadism) 0.65))
  (effects
    (mint-emotion contempt ?actor 48)))

(npc-reflex {?actor betray_act ?patient}:?c
  (when (> (attr @self sadism) 0.65))
  (effects
    (mint-emotion joy @nothing 12)
    (mint-emotion pride @self 24)))

; -- degrade_act (a deliberated PUBLIC put-down): the audience makes the
; injury a STATUS event - shame + status_loss plus anger at the mocker.
(npc-reflex {?actor degrade_act @self}:?c
  (effects
    (mint-emotion shame @nothing 720)
    (mint-emotion anger ?actor 168)
    (mint-pressure humiliation ?actor 1440)
    (mint-pressure status_loss @nothing 1440)))

(npc-reflex {@self degrade_act ?patient}:?c
  (effects
    (mint-emotion pride @self 24)))

(npc-reflex {?actor degrade_act ?patient}:?c
  (effects
    (mint-emotion contempt ?actor 24)))

; -- expose_act (public disclosure of a band-4+ secret) --
(npc-reflex {?actor expose_act @self}:?c
  (effects
    (mint-emotion shame @nothing 720)
    (mint-pressure humiliation ?actor 1440)
    (mint-pressure status_loss @nothing 2160)))

(npc-reflex {@self expose_act ?patient}:?c
  (effects
    (mint-pressure exposure_risk ?patient 720)))

; -- repudiation_act (a husband divorces an adulterous wife): the disgrace
; lands on the PATIENT; third parties side with the wronged husband, so their
; contempt targets HER.
(npc-reflex {?actor repudiation_act @self}:?c
  (effects
    (mint-emotion shame @nothing 2160)
    (mint-emotion grief ?actor 720)
    (mint-pressure status_loss @nothing 4320)
    (mint-pressure attachment_loss ?actor 1440)
    (end-bond {@self love ?actor})
    (end-bond {@self friend ?actor})))

(npc-reflex {?actor repudiation_act ?patient}:?c
  (effects
    (mint-emotion contempt ?patient 96)))

; -- abandonment_act (disinheritance / desertion) --
(npc-reflex {?actor abandonment_act @self}:?c
  (effects
    (mint-emotion grief ?actor 720)
    (mint-emotion distress @nothing 168)
    (mint-pressure attachment_loss ?actor 2160)
    (mint-pressure status_loss @nothing 1440)
    (end-bond {@self friend ?actor})
    (end-bond {@self love ?actor})))

(npc-reflex {@self abandonment_act ?patient}:?c
  (effects
    (mint-emotion guilt @self 720)
    (mint-pressure moral_violation @self 1440)))

(npc-reflex {?actor abandonment_act ?patient}:?c
  (effects
    (mint-emotion distress ?actor 48)
    ; 60 days; shorter decayed before the monthly deliberate could see it.
    (mint-pressure injustice ?actor (* 1440 (mobilisation-scale ?patient)))))

; -- aid_act / provision_act / help_act (direct assistance / giving). A single
; favour is a WARMTH nudge, not an instant friendship: gratitude couples to
; warmth, repeated kindnesses accumulate into a like band, friendship then
; forms via the warmth-biased befriend rules.
(npc-reflex {?actor help_act @self}:?c
  (effects
    (mint-emotion gratitude ?actor 168)
    (mint-emotion relief @nothing 72)))

(npc-reflex {@self help_act ?patient}:?c
  (effects
    (mint-emotion pride @self 72)))

(npc-reflex {?actor help_act ?patient}:?c
  (effects
    (mint-emotion affection ?actor 48)))

(npc-reflex {?actor aid_act @self}:?c
  (effects
    (mint-emotion gratitude ?actor 168)))

(npc-reflex {?actor provision_act @self}:?c
  (effects
    (mint-emotion gratitude ?actor 168)))

; -- honour_act / commitment_act. Honour mints admiration toward the actor;
; the stance coupling routes it to esteem (the retired `respects` attitude).
(npc-reflex {?actor honour_act @self}:?c
  (effects
    (mint-emotion pride @self 168)
    (mint-emotion gratitude ?actor 168)
    (mint-emotion admiration ?actor 168)))

(npc-reflex {@self honour_act ?patient}:?c
  (effects
    (mint-emotion pride @self 72)))

(npc-reflex {?actor honour_act ?patient}:?c
  (effects
    (mint-emotion affection ?actor 48)))

(npc-reflex {?actor commitment_act @self}:?c
  (effects
    (mint-emotion gratitude ?actor 168)))
