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
;     (era_max       <year>))                 ; default 9999
;
; Job names MUST match Concepts.mon. Add to Concepts.mon first if missing.
; ----------------------------------------------------------------------------

;; --- Upper-class professions ---
(job banker        (class_floor middle) (business_type bank)           (may_own true)  (bootstrap true) (era_min 1700))
(job industrialist (class_floor upper)  (business_type factory)        (may_own true)  (era_min 1830))
(job landlord      (class_floor middle)                                (may_own true)  (era_min 1700))
(job merchant      (class_floor middle) (business_type shipping_agent) (may_own true)  (era_min 1700))
(job proprietor    (class_floor middle)                                (may_own true)  (era_min 1700))
(job solicitor     (class_floor middle) (business_type solicitor_firm) (may_own true)  (bootstrap true) (era_min 1700))
(job physician     (class_floor middle) (business_type hospital)       (may_own false) (era_min 1700))
(job surgeon       (class_floor middle) (business_type hospital)       (may_own false) (era_min 1780))
; apothecary is not bootstrapped: Concepts.mon has no `apothecary` business
; kind (org > com > business > ...). Add one, then restore (bootstrap true).
(job apothecary    (class_floor middle) (business_type apothecary)     (may_own true)  (era_min 1700))
(job priest        (class_floor middle) (business_type church)         (may_own false) (era_min 1700))
(job principal     (class_floor middle) (business_type private_school) (may_own false) (era_min 1700))

;; --- Middle-class professions ---
(job editor        (class_floor middle) (business_type newspaper)      (may_own true)  (era_min 1750))
(job journalist    (class_floor middle) (business_type newspaper)      (may_own false) (era_min 1750))
(job printer       (class_floor middle) (business_type newspaper)      (may_own false) (era_min 1700))
(job teacher       (class_floor middle) (business_type state_school)   (may_own false) (era_min 1700))
(job engineer      (class_floor middle)                                (may_own false) (era_min 1820))
(job clerk         (class_floor middle)                                (may_own false) (era_min 1700))
(job typist        (class_floor middle)                                (may_own false) (era_min 1875))
(job house_agent   (class_floor middle) (business_type house_agency)   (may_own true)  (era_min 1820))
(job librarian     (class_floor middle) (business_type library)        (may_own false) (era_min 1700))
(job curator       (class_floor middle) (business_type museum)         (may_own false) (era_min 1700))

;; --- Lower-class trades + service ---
(job bartender      (class_floor lower) (business_type pub)        (may_own false) (bootstrap true) (era_min 1700))
(job barber         (class_floor lower) (business_type barbershop) (may_own false) (era_min 1700))
(job cook           (class_floor lower)                            (may_own false) (era_min 1700))
(job farmer         (class_floor lower)                            (may_own false) (era_min 1700))
(job gardener       (class_floor lower)                            (may_own false) (era_min 1700))
(job maid           (class_floor lower)                            (may_own false) (era_min 1700))
(job nurse          (class_floor lower) (business_type hospital)   (may_own false) (era_min 1700))
(job shop_clerk     (class_floor lower) (business_type grocer)     (may_own false) (bootstrap true) (era_min 1700))
(job waiter         (class_floor lower) (business_type restaurant) (may_own false) (era_min 1700))
(job factory_worker (class_floor lower) (business_type factory)    (may_own false) (era_min 1830))
