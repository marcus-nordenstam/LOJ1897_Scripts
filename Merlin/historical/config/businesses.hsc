; ----------------------------------------------------------------------------
; businesses.hsc
;
; Metadata layer over the org kinds already declared in Concepts.mon
; (org > com|gov|edu > ...). Drives premises selection when an org is founded:
; which BUILDING kind to spawn for it, which ROOM inside that building holds
; its records (the back-office), and whether it needs premises at all.
;
; Form:
;   (business <org-kind>
;     (building          <commercial_building leaf>) ; premises spawned at founding; default office
;     (back_office_room  <room kind>)                ; room that holds the org's records; default back_office
;     (premises          on_site|residence))         ; on_site (default) = spawn a building;
;                                                     ; residence = a sole proprietor runs it from
;                                                     ; their own home (the back_office_room is a room
;                                                     ; of their residence, e.g. their study) UNTIL the
;                                                     ; business outgrows it (see estate_scale_threshold).
;
;   (estate_scale_threshold <N>)                     ; a residence-seated business that comes to own
;                                                     ; >= N titled properties opens an on-site office
;                                                     ; (its building kind) and hires a house_agent.
;
; Org kinds MUST match Concepts.mon; building kinds MUST be commercial_building
; leaves (Objects.mon); room kinds MUST be `room` sub-kinds (Spaces.mon). An
; org kind not listed here defaults to (building office) (back_office_room
; back_office) (premises on_site). ';' or '#' line comments.
; ----------------------------------------------------------------------------

;; --- Industrial / financial: each needs its own building ---
(business factory        (building factory))
(business bank           (building bank))
(business newspaper      (building newspaper))

;; --- Retail (a customer-facing shop with a counter); records in the back office ---
(business shop           (building shop))
(business grocer         (building shop))
(business apothecary     (building shop))
(business bookseller     (building shop))
(business pawnbroker     (building shop))
(business antiques_shop  (building shop))
(business barbershop     (building barbershop))

;; --- Hospitality / leisure: their own premises ---
(business hotel          (building hotel))
(business restaurant     (building restaurant))
(business pub            (building pub))
(business theatre        (building theatre))

;; --- Professional / agency: a general office building where clients call ---
(business solicitor_firm (building office))
(business house_agency   (building office))
(business insurance_co   (building office))
(business shipping_agent (building office))
;; Clubs convene in their own clubhouse, not an office (activity-lanes L8).
;; Athletic clubs are founded as the concrete leaves race_club / athletic_club
;; (k_foundable_club_kinds); social clubs (the named institutions) are pre-placed
;; instances of social_club. The catalog lookup is per-leaf.
(business race_club      (building athletic_clubhouse))
(business athletic_club  (building athletic_clubhouse))
(business social_club    (building social_clubhouse))

;; --- Public (gov / edu): bootstrapped, but premises kind declared for completeness ---
(business church         (building church))
(business hospital       (building hospital))
(business state_school   (building school))
(business private_school (building school))

;; --- Public civic / cultural venues (govt-bootstrap via public_orgs.hsc).
;;     Each occupies its own dedicated building; these are the interest-lane
;;     venues an enthusiast pursues their interest at (activity-lanes L5). ---
(business library        (building library))
(business museum         (building museum))
(business meeting_hall   (building meeting_hall))
(business sports_ground  (building sports_ground))

;; --- The landlord's estate: a sole proprietor runs it from his study (the
;;     let dwellings ARE the customer-facing area). Once it owns enough
;;     property it opens an on-site office and hires a house_agent. ---
(business estate         (building office) (back_office_room study) (premises residence))

(estate_scale_threshold 5)
