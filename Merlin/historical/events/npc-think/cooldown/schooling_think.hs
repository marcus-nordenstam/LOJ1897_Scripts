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
; their family - deliver_child). A breeding-graded chance routes upper
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
  (cooldown 1 m)
  (rng-stream behaviour)

  ; MAINTENANCE: the decision OWNS the enrol_primary goal end to end. @self is a child
  ; who does not yet hold the basic-schooling credential; the (not skilled_in) guard
  ; keeps a once-schooled child from re-enrolling on a later month of the 5-7 window.
  (role @self
              (not (believes {@self skilled_in [k primary_school_curriculum]})))

  ; ONSET: the breeding-squared class-gate (chance) is rolled at the fire and LOCKED once
  ; holding (it re-rolls each month until it lands), routing an upper child (breeding
  ; ~0.85) into school almost always, a working-class child (~0.25) only rarely.
  ; CONTINUOUS completion gate: while the child is not yet studying primary the goal
  ; stands; the moment enrol_primary_act matriculates him ({@self study [k
  ; primary_school_curriculum]}) it falls and the goal ends. The act never ends the goal.
  (when (and (>= (years-old @self) 5)
             (<= (years-old @self) 7)
             (not (believes {@self study [k primary_school_curriculum]}))
             (latch-eval (chance (* 0.0833 (situation @self breeding) (situation @self breeding))))))

  (effects       (begin-goal {@self enrol_primary}))
  (cease-effects (end-goal   {@self enrol_primary})))

; --- enroll_secondary: a middle+ youth goes on to secondary ------------------
(npc-think enroll_secondary
  (cooldown 1 m)
  (rng-stream behaviour)

  ; MAINTENANCE: the decision OWNS the enrol_secondary goal end to end. @self holds the
  ; primary credential, is not yet secondary-credentialed, and is not in work /
  ; apprenticeship (the working-class child who finished primary has a low chance and
  ; instead falls to apprenticeship_start, which excludes pupils).
  (role @self
              (believes {@self skilled_in [k primary_school_curriculum]})
              (not (believes {@self skilled_in [k secondary_school_curriculum]}))
              (not (believes {@self employer ?})))

  ; ONSET: the middle+ breeding-squared (chance) is rolled at the fire and LOCKED once
  ; holding. CONTINUOUS completion gate: the goal ends when enrol_secondary_act
  ; matriculates him ({@self study [k secondary_school_curriculum]}).
  (when (and (>= (years-old @self) 12)
             (<= (years-old @self) 14)
             (not (believes {@self study [k secondary_school_curriculum]}))
             (latch-eval (chance (* 0.0833 (situation @self breeding) (situation @self breeding))))))

  (effects       (begin-goal {@self enrol_secondary}))
  (cease-effects (end-goal   {@self enrol_secondary})))

; --- enroll_university: an upper / wealthy youth goes up to university --------
(npc-think enroll_university
  (cooldown 1 m)
  (rng-stream behaviour)

  ; MAINTENANCE: the decision OWNS the enrol_university goal end to end. @self is
  ; secondary-educated and not employed. The subject is interest-led, chosen inside the
  ; act - enrol_university_act mints {@self study <academic_field>} (medicine / law /
  ; ...), NOT a fixed university curriculum, so the completion gate is the generic (not
  ; (believes {@self study ?})): at 18-20 the youth holds no prior study, so it falls
  ; exactly when he matriculates.
  (role @self
              (believes {@self skilled_in [k secondary_school_curriculum]})
              (not (believes {@self employer ?})))

  ; ONSET: the steep upper / wealthy-middle breeding-cubed (chance) - the professions'
  ; gateway - rolled at the fire and LOCKED once holding. CONTINUOUS completion gate:
  ; the goal ends when enrol_university_act matriculates him ({@self study <subject>}).
  (when (and (>= (years-old @self) 18)
             (<= (years-old @self) 20)
             (not (believes {@self study ?}))
             (latch-eval (chance (* 0.0833 (situation @self breeding) (* (situation @self breeding) (situation @self breeding)))))))

  (effects       (begin-goal {@self enrol_university}))
  (cease-effects (end-goal   {@self enrol_university})))

; --- leave_primary: every primary pupil finishes at ~11 ----------------------
(npc-think leave_primary
  (cooldown 1 m)
  (rng-stream behaviour)

  ; Deterministic: @self, a primary pupil who has reached the leaving age, takes
  ; the basic-schooling credential (graduate mints skilled_in primary_school_
  ; curriculum at novice and ends the study). The credential then gates secondary
  ; enrollment; a non-continuer becomes apprenticeship-eligible. Monthly firing is
  ; idempotent - the first fire ends the study, so later months no-op. age -> (when).
  (role @self 
              (believes {@self study [k primary_school_curriculum]}))

  (when (>= (years-old @self) 11))

  (effects
    (graduate-from-study)
    ))

; --- leave_secondary: a secondary pupil finishes at ~17 ----------------------
(npc-think leave_secondary
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self 
              (believes {@self study [k secondary_school_curriculum]}))

  (when (>= (years-old @self) 17))

  (effects
    (graduate-from-study)
    ))

; --- graduate_university: a degree is taken at ~22 ---------------------------
(npc-think graduate_university
  (cooldown 1 m)
  (rng-stream behaviour)

  ; Any ongoing study at 22+ is a university degree (primary / secondary pupils
  ; are <18 and have already left). graduate-from-study mints the subject credential
  ; {@self skilled_in <subject> trained}, feeding the S8 physician / lawyer /
  ; scholar identities + the prestige bump - the profession pipeline payoff.
  (role @self 
              (believes {@self study ?}))

  (when (>= (years-old @self) 22))

  (effects
    (graduate-from-study)
    ))
