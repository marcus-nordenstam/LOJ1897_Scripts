; ----------------------------------------------------------------------------
; occupations.hs
;
; Metadata layer over the job symbols already declared in Concepts.mon
; (org_pos > job > ...). Annotates each job with what the historical sim needs
; at occupation-binding time (the HIRING match).
;
; Form:
;   (job <name>
;     (class_floor   <lower|middle|upper>)    ; minimum class allowed (HARD gate)
;     (business_type <symbol>)                ; optional, ties job to a business kind
;     (may_own       <true|false>)            ; default false
;     ; --- Hiring requirements (Section 4.11 career model). Eligibility is a
;     ;     MATCH of these against the candidate, NOT a flat random chance. ---
;     (req_repute    <band>)                  ; HARD: min reputation band
;                                             ; (respectable / exemplary). Trust-
;                                             ; sensitive posts (banking, clerical,
;                                             ; the professions, service in a
;                                             ; reputable house) gate on it.
;     (req_skill     <domain> [<band>])       ; HARD, repeatable: must hold
;                                             ; {@self skilled_in <domain>} at the
;                                             ; band (novice<trained<expert). Both
;                                             ; education credentials (school
;                                             ; curricula, university degrees) AND
;                                             ; tenure-conferred domain skill are
;                                             ; skilled_in entries, so this doubles
;                                             ; as the EXPERIENCE requirement.
;                                             ; ONLY gate ADVANCED rungs reachable
;                                             ; from a degree or in-domain tenure -
;                                             ; an ENTRY job must NOT require its own
;                                             ; domain (you learn it on the job), or
;                                             ; nobody could ever be hired into it.
;     (pref_trait    <attr> [<weight>]))      ; SOFT, repeatable: preferred
;                                             ; personality. Scores the match among
;                                             ; the eligible (never blocks a hire).
;
; The `domain` a job CONFERS competence in (S4 derive_skills grows
; {@self skilled_in <domain>} from tenure) lives in tables/occupation_domains.hs.
;
; THE LADDER (why some jobs carry req_skill and entry jobs do not):
;   clerk (entry, learns accountancy on the job) --tenure--> banker (req
;   accountancy trained). engineer (entry) --tenure--> industrialist (req
;   engineering trained). journalist (entry) --tenure--> editor (req literature
;   trained). University degree --> physician/surgeon (medicine trained),
;   solicitor (law trained). Secondary credential --> teacher/principal.
;
; Lower-class trades carry NO hard gates - the on-ramp must stay open; they only
; express preferred traits.
;
; Job names MUST match Concepts.mon. Repute bands are `respectability_situation`
; leaves; trait names are personality attrs (common.arc).
; ----------------------------------------------------------------------------

;; --- Upper-class professions ---
(job banker        
   (class_floor middle) 
   (business_type bank)           
   (may_own true)
   (req_repute respectable) 
   (req_skill accountancy trained)
   (pref_trait industriousness 1.0) 
   (pref_trait politeness 0.6))

(job industrialist 
   (class_floor upper)  
   (business_type factory)
   (may_own true)
   (req_repute respectable) 
   (req_skill engineering trained)
   (pref_trait assertiveness 1.0) 
   (pref_trait industriousness 0.8))

(job landlord      
   (class_floor middle)
   (may_own true)
   (req_repute respectable)
   (pref_trait assertiveness 0.8) 
   (pref_trait industriousness 0.6))

(job merchant      
   (class_floor middle) 
   (business_type shipping_agent) 
   (may_own true)
   (pref_trait assertiveness 1.0) 
   (pref_trait enthusiasm 0.6))

(job proprietor    
   (class_floor middle) 
   (may_own true)
   (pref_trait assertiveness 0.8) 
   (pref_trait industriousness 0.8))

(job solicitor     
   (class_floor middle) 
   (business_type solicitor_firm) 
   (may_own true)
   (req_repute respectable) 
   (req_skill law trained)
   (pref_trait industriousness 1.0) 
   (pref_trait openness 0.5))

(job physician     
   (class_floor middle)
   (business_type hospital)
   (may_own false)
   (req_repute respectable)
   (req_skill medicine trained)
   (pref_trait compassion 0.8) 
   (pref_trait industriousness 0.8))

(job surgeon
   (class_floor middle) 
   (business_type hospital)
   (may_own false)
   (req_repute respectable)
   (req_skill medicine trained)
   (pref_trait industriousness 1.0)
   (pref_trait assertiveness 0.5))

; apothecary: may_own + business_type, so entered by founding OR hired as a
; junior who learns medicine on the counter (no req_skill - the on-ramp).
(job apothecary    
   (class_floor middle)
   (business_type apothecary)
   (may_own true)
   (req_repute respectable)
   (pref_trait industriousness 0.8))

; A priest keeps irregular hours and the week is NOT Mon-Sat (Sunday is the
; working day). work_schedule names the working days explicitly; omitted days
; are off.
(job priest
   (class_floor middle)
   (business_type church)
   (may_own false)
   (req_repute respectable)
   (work_schedule (sunday 8am 1pm)
   (wednesday 10am 12pm)
   (saturday 4pm 6pm))
   (pref_trait politeness 0.8)
   (pref_trait compassion 0.8))

(job principal
   (class_floor middle)
   (business_type private_school)
   (may_own false)
   (req_repute respectable)
   (req_skill secondary_school_curriculum trained)
   (pref_trait politeness 0.8)
   (pref_trait industriousness 0.8))

; professor: the university don. No conferred domain: a don's competence
; is the degree they earned (minted at graduation), not a skill the post confers.
(job professor
   (class_floor upper)
   (business_type university)
   (may_own false)
   (req_repute respectable)
   (pref_trait openness 1.0)
   (pref_trait industriousness 0.6))

;; --- Middle-class professions ---
; editor: the senior newspaper post, reached by a journalist who has built the
; literature domain on the job.
(job editor
   (class_floor middle)
   (business_type newspaper)
   (may_own true)
   (req_repute respectable)
   (req_skill literature trained)
   (pref_trait openness 0.8)
   (pref_trait assertiveness 0.6))

; journalist: ENTRY to the literature domain (no req_skill - learns on the job).
(job journalist
   (class_floor middle)
   (business_type newspaper)
   (may_own false)
   (pref_trait openness 1.0)
   (pref_trait enthusiasm 0.6))

(job printer
   (class_floor middle)
   (business_type newspaper)
   (may_own false)
   (pref_trait industriousness 0.8))

(job teacher
   (class_floor middle)
   (business_type state_school)
   (may_own false)
   (req_repute respectable)
   (req_skill secondary_school_curriculum novice)
   (pref_trait politeness 0.8)
   (pref_trait compassion 0.6))

; engineer: ENTRY to the engineering domain (no req_skill - learns on the job;
; the senior rung is industrialist, which requires engineering trained).
(job engineer
   (class_floor middle)
   (may_own false)
   (pref_trait industriousness 1.0)
   (pref_trait openness 0.5))

; clerk: ENTRY to accountancy (no req_skill - learns the books on the job; the
; senior rung is banker, which requires accountancy trained). Clerical work needs
; a respectable name (the user's ruling).
(job clerk
   (class_floor middle)
   (may_own false)
   (req_repute respectable)
   (pref_trait industriousness 1.0) (pref_trait politeness 0.5))

(job typist
   (class_floor middle)
   (may_own false)
   (req_repute respectable)
   (pref_trait industriousness 0.8))

(job house_agent
   (class_floor middle)
   (business_type house_agency)
   (may_own true)
   (req_repute respectable)
   (pref_trait assertiveness 1.0)
   (pref_trait enthusiasm 0.6))

; librarian / curator: ENTRY to literature / history (no req_skill).
(job librarian
   (class_floor middle)
   (business_type library)
   (may_own false)
   (pref_trait openness 0.8)
   (pref_trait politeness 0.6))

(job curator
   (class_floor middle)
   (business_type museum)
   (may_own false)
   (pref_trait openness 0.8)
   (pref_trait politeness 0.6))

;; --- Lower-class trades + service (no hard gates - the on-ramp stays open) ---
(job bartender
   (class_floor lower)
   (business_type pub)
   (may_own false)
   (pref_trait enthusiasm 0.8))

(job barber
   (class_floor lower)
   (business_type barbershop)
   (may_own false)
   (pref_trait enthusiasm 0.6))

(job cook 
   (class_floor lower)
   (may_own false)
   (pref_trait industriousness 0.6))

(job farmer
   (class_floor lower)
   (may_own false)
   (pref_trait industriousness 0.8))

(job gardener
   (class_floor lower)
   (may_own false)
   (pref_trait industriousness 0.6))

(job maid
   (class_floor lower)
   (may_own false)
   (pref_trait industriousness 0.6) (pref_trait politeness 0.5))

; A hospital runs ROUND THE CLOCK, so a nurse is assigned ONE of two shifts at
; hire (day or night) - two `shift` clauses; the night shift wraps past midnight.
(job nurse
   (class_floor lower)
   (business_type hospital)
   (may_own false)
   (shift (monday 7am 7pm) (tuesday 7am 7pm) (wednesday 7am 7pm) (thursday 7am 7pm) (friday 7am 7pm) (saturday 7am 7pm) (sunday 7am 7pm))
   (shift (monday 7pm 7am) (tuesday 7pm 7am) (wednesday 7pm 7am) (thursday 7pm 7am) (friday 7pm 7am) (saturday 7pm 7am) (sunday 7pm 7am))
   (pref_trait compassion 1.0) 
   (pref_trait industriousness 0.6))

(job shop_clerk
   (class_floor lower) 
   (business_type grocer)
   (may_own false)
   (pref_trait enthusiasm 0.6)
   (pref_trait politeness 0.5))

(job waiter         
   (class_floor lower) 
   (business_type restaurant) 
   (may_own false)
   (pref_trait politeness 0.6) 
   (pref_trait enthusiasm 0.5))

; A factory runs day AND night shifts; a hand is assigned one at hire.
(job factory_worker 
   (class_floor lower) 
   (business_type factory)    
   (may_own false)
   (shift (monday 6am 6pm) (tuesday 6am 6pm) (wednesday 6am 6pm) (thursday 6am 6pm) (friday 6am 6pm) (saturday 6am 6pm))
   (shift (monday 6pm 6am) (tuesday 6pm 6am) (wednesday 6pm 6am) (thursday 6pm 6am) (friday 6pm 6am) (saturday 6pm 6am))
   (pref_trait industriousness 0.6))

; jockey: professional race rider, employed by a race_club. The annual
; horse_racing meet (hold-sporting-event) admits ONLY jockey-job roster
; entries as riders; the club tops its string up to the jockey headcount
; before each meet from the jobless lower-class adult male pool.
(job jockey
   (class_floor lower) 
   (business_type race_club)  
   (may_own false)
   (pref_trait assertiveness 0.6))
