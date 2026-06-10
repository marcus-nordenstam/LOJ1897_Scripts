; ----------------------------------------------------------------------------
; occupations.hsc
;
; Metadata layer over the job symbols already declared in Concepts.mon
; (org_pos > job > ...). Annotates the existing ontology with what the
; historical sim needs at occupation-binding time.
;
; Form:
;   (job <name>
;     (class_floor   <lower|middle|upper>)    ; minimum class allowed
;     (business_type <symbol>)                ; optional, ties job to a business kind
;     (may_own       <true|false>)            ; default false
;     (bootstrap     <true|false>)            ; default false; org pre-exists at sim start
;     (era_min       <year>)                  ; default 1700
;     (era_max       <year>)                  ; default 9999
;     (domain        <leaf>))                 ; optional; a `domain` leaf this job
;                                             ; confers competence in. PR-skill-life
;                                             ; S4 derives {@self skilled_in <leaf>}
;                                             ; from employer-tenure for any job that
;                                             ; names a domain. Jobs with no domain
;                                             ; (unskilled service trades) confer none.
;
; Job names MUST match Concepts.mon. Add to Concepts.mon first if missing.
; Domain leaves MUST be `domain` sub-kinds (Concepts.mon `domain` tree).
; ----------------------------------------------------------------------------

;; --- Upper-class professions ---
(job banker        (class_floor middle) (business_type bank)           (may_own true)  (bootstrap true) (era_min 1700) (domain accountancy))
(job industrialist (class_floor upper)  (business_type factory)        (may_own true)  (era_min 1830) (domain engineering))
(job landlord      (class_floor middle)                                (may_own true)  (era_min 1700) (domain commerce))
(job merchant      (class_floor middle) (business_type shipping_agent) (may_own true)  (era_min 1700) (domain commerce))
(job proprietor    (class_floor middle)                                (may_own true)  (era_min 1700) (domain commerce))
(job solicitor     (class_floor middle) (business_type solicitor_firm) (may_own true)  (bootstrap true) (era_min 1700) (domain law))
(job physician     (class_floor middle) (business_type hospital)       (may_own false) (era_min 1700) (domain medicine))
(job surgeon       (class_floor middle) (business_type hospital)       (may_own false) (era_min 1780) (domain medicine))
; apothecary: the business kind exists (businesses.hs `(business apothecary
; (building shop))`, Concepts.mon org kind), so the shop bootstraps and is
; staffed - the poison-register counter the purchase trail needs
; (jilt_blackmail_reputation_plan sec 5 / serial-predation pipeline).
(job apothecary    (class_floor middle) (business_type apothecary)     (may_own true)  (bootstrap true) (era_min 1700) (domain medicine))
(job priest        (class_floor middle) (business_type church)         (may_own false) (era_min 1700) (domain theology))
(job principal     (class_floor middle) (business_type private_school) (may_own false) (era_min 1700) (domain secondary_school_curriculum))
; professor: the university don (PR-education). No (domain ...): a don's competence
; is the degree they earned (minted at graduation), not a skill the post confers.
(job professor     (class_floor upper)  (business_type university)     (may_own false) (era_min 1700))

;; --- Middle-class professions ---
(job editor        (class_floor middle) (business_type newspaper)      (may_own true)  (era_min 1750) (domain literature))
(job journalist    (class_floor middle) (business_type newspaper)      (may_own false) (era_min 1750) (domain literature))
(job printer       (class_floor middle) (business_type newspaper)      (may_own false) (era_min 1700) (domain literature))
(job teacher       (class_floor middle) (business_type state_school)   (may_own false) (era_min 1700) (domain secondary_school_curriculum))
(job engineer      (class_floor middle)                                (may_own false) (era_min 1820) (domain engineering))
(job clerk         (class_floor middle)                                (may_own false) (era_min 1700) (domain accountancy))
(job typist        (class_floor middle)                                (may_own false) (era_min 1875) (domain accountancy))
(job house_agent   (class_floor middle) (business_type house_agency)   (may_own true)  (era_min 1820) (domain commerce))
(job librarian     (class_floor middle) (business_type library)        (may_own false) (era_min 1700) (domain literature))
(job curator       (class_floor middle) (business_type museum)         (may_own false) (era_min 1700) (domain history))

;; --- Lower-class trades + service ---
(job bartender      (class_floor lower) (business_type pub)        (may_own false) (bootstrap true) (era_min 1700))
(job barber         (class_floor lower) (business_type barbershop) (may_own false) (era_min 1700))
(job cook           (class_floor lower)                            (may_own false) (era_min 1700))
(job farmer         (class_floor lower)                            (may_own false) (era_min 1700) (domain husbandry))
(job gardener       (class_floor lower)                            (may_own false) (era_min 1700) (domain husbandry))
(job maid           (class_floor lower)                            (may_own false) (era_min 1700))
(job nurse          (class_floor lower) (business_type hospital)   (may_own false) (era_min 1700) (domain medicine))
(job shop_clerk     (class_floor lower) (business_type grocer)     (may_own false) (bootstrap true) (era_min 1700))
(job waiter         (class_floor lower) (business_type restaurant) (may_own false) (era_min 1700))
(job factory_worker (class_floor lower) (business_type factory)    (may_own false) (era_min 1830))
