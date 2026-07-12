; ----------------------------------------------------------------------------
; Schooling (PR-education). Class-gated late-Victorian education as a skill /
; interest path - the corrected successor to PR-skill-life's deferred education
; sub-parts (S3 education_exposure + the backlog's skill_formal_education).
; Enrollment tier = f(class); the university SUBJECT = f(interest).
;
; Model (1700-1897):
;   No school   : working-class, unsupported -> straight to child labour /
;                 apprenticeship (apprenticeship_start, age 12-16, breeding-gated).
;   Primary     : working-class lucky + middle+ -> state primary (~5-11).
;   Secondary   : middle+ -> primary then secondary (~12-17).
;   University  : upper / wealthy-middle -> a chartered subject degree (~18-22),
;                 the subject chosen by the youth's own interest.
;
; Substrate - NO new ontology; reuses the existing education-life-cycle relation
; `study (tar @excl academic_field) (aux org)` and the `skilled_in` credential:
;   {pupil study <curriculum-or-subject>}        - the ongoing enrollment interval.
;   {pupil skilled_in <curriculum> /aux <band>}  - the credential minted at
;        graduation: primary -> novice, secondary / university subject -> trained.
;   A university subject credential (medicine / law / ...) at trained feeds the
;   PR-skill-life S8 physician / lawyer / scholar identities + the prestige bump,
;   closing the class -> education -> profession -> prestige -> class loop.
;
; The CLASS GATE is the `breeding` lineage anchor (0..1, birth-seeded, stable
; across the 15+ class_situation re-derivation; in-sim children inherit it from
; their family - run_effect_birth_human). A breeding-graded chance routes upper
; children into school and working-class children toward apprenticeship - no hard
; class read needed (breeding IS the heritable class signal). The pattern mirrors
; apprenticeship_start, which gates childhood eligibility on the same anchor.
;
; FLOW (annual; enroll in spring / early summer, leave in autumn, so a continuer
; is enrolled in the next tier before the leave pass could re-fire that year):
;   enroll_primary (5-7)        -> leave_primary (>=11)     [primary credential]
;   enroll_secondary (12-14)    -> leave_secondary (>=17)   [secondary credential]
;   enroll_university (18-20)   -> graduate_university (>=22)[subject credential]
; The leave / graduate events are DETERMINISTIC at the tier's leaving age (the
; age IS the gate, no chance jitter); (graduate-from-study) reads the ongoing study
; and mints the tier credential, deriving the tier from the study target.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- enroll_primary: a young child starts primary school ---------------------
(npc-think enroll_primary
  (sim-window-think)
  (rng-stream behaviour)

  ; The child (@self) is the subject, not yet schooled. The two (not ...) belief
  ; guards keep a once-schooled child from re-enrolling on a later month of the
  ; 5-7 window. age + the breeding-squared class-gate chance are non-belief ops ->
  ; (when); the chance carries the /12 annual->monthly factor (now per-month). The
  ; breeding-squared gate routes an upper child (breeding ~0.85) into school almost
  ; always, a working-class child (~0.25) only rarely.
  (role @self (any_human @self)
              (not (believes {@self study ?}))
              (not (believes {@self skilled_in [k primary_school_curriculum]})))

  (when (and (>= (years-old @self) 5)
             (<= (years-old @self) 7)
             (chance (* 0.0833 (situation @self breeding) (situation @self breeding)))))

  ; SPLIT (Item 5): the npc-think - the decision to school the child. Mints
  ; {@self goal {@self enrol_primary}}; the npc-act (schooling_errands.hs) walks
  ; the child to a school and enrols him there.
  (effects
    (begin-goal {@self enrol_primary})))

; --- enroll_secondary: a middle+ youth goes on to secondary ------------------
(npc-think enroll_secondary
  (sim-window-think)
  (rng-stream behaviour)

  ; @self completed primary (holds the credential), not currently enrolled, not
  ; yet in work / apprenticeship. age + the middle+ breeding-squared gate -> (when)
  ; (with /12 monthly factor). The working-class child who finished primary has a
  ; low chance and instead falls to apprenticeship_start (which excludes pupils).
  (role @self (any_human @self)
              (believes {@self skilled_in [k primary_school_curriculum]})
              (not (believes {@self study ?}))
              (not (believes {@self skilled_in [k secondary_school_curriculum]}))
              (not (believes {@self employer ?})))

  (when (and (>= (years-old @self) 12)
             (<= (years-old @self) 14)
             (chance (* 0.0833 (situation @self breeding) (situation @self breeding)))))

  ; SPLIT (Item 5): npc-think -> {@self goal {@self enrol_secondary}}; the act
  ; (schooling_errands.hs) walks the youth to school and enrols him.
  (effects
    (begin-goal {@self enrol_secondary})))

; --- enroll_university: an upper / wealthy youth goes up to university --------
(npc-think enroll_university
  (sim-window-think)
  (rng-stream behaviour)

  ; @self is secondary-educated, not enrolled, not employed. age + the steep
  ; upper / wealthy-middle breeding-cubed gate (the professions' gateway) -> (when)
  ; (with /12 monthly factor). The subject is interest-led, chosen inside the act.
  (role @self (any_human @self)
              (believes {@self skilled_in [k secondary_school_curriculum]})
              (not (believes {@self study ?}))
              (not (believes {@self employer ?})))

  (when (and (>= (years-old @self) 18)
             (<= (years-old @self) 20)
             (chance (* 0.0833 (situation @self breeding) (* (situation @self breeding) (situation @self breeding))))))

  ; SPLIT (Item 5): npc-think -> {@self goal {@self enrol_university}}; the act
  ; (schooling_errands.hs) takes the youth up to university and matriculates him.
  (effects
    (begin-goal {@self enrol_university})))

; --- leave_primary: every primary pupil finishes at ~11 ----------------------
(npc-think leave_primary
  (sim-window-think)
  (rng-stream behaviour)

  ; Deterministic: @self, a primary pupil who has reached the leaving age, takes
  ; the basic-schooling credential (graduate mints skilled_in primary_school_
  ; curriculum at novice and ends the study). The credential then gates secondary
  ; enrollment; a non-continuer becomes apprenticeship-eligible. Monthly firing is
  ; idempotent - the first fire ends the study, so later months no-op. age -> (when).
  (role @self (any_human @self)
              (believes {@self study [k primary_school_curriculum]}))

  (when (>= (years-old @self) 11))

  (effects
    (graduate-from-study)
    ))

; --- leave_secondary: a secondary pupil finishes at ~17 ----------------------
(npc-think leave_secondary
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (any_human @self)
              (believes {@self study [k secondary_school_curriculum]}))

  (when (>= (years-old @self) 17))

  (effects
    (graduate-from-study)
    ))

; --- graduate_university: a degree is taken at ~22 ---------------------------
(npc-think graduate_university
  (sim-window-think)
  (rng-stream behaviour)

  ; Any ongoing study at 22+ is a university degree (primary / secondary pupils
  ; are <18 and have already left). graduate-from-study mints the subject credential
  ; {@self skilled_in <subject> trained}, feeding the S8 physician / lawyer /
  ; scholar identities + the prestige bump - the profession pipeline payoff.
  (role @self (any_human @self)
              (believes {@self study ?}))

  (when (>= (years-old @self) 22))

  (effects
    (graduate-from-study)
    ))
