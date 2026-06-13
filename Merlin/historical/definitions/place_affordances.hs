; ----------------------------------------------------------------------------
; place_affordances.hs
;
; Phase 0 of the place-and-time-centric reframe (Docs/future_work.md Section 4).
; A metadata layer over the building kinds in Objects.mon: for each PLACE kind,
; the events it can host (its affordances) and who it draws, by day-band.
;
; This is authored data ONLY. In Phase 0 NOTHING reads it - loading it changes
; no behaviour. Phase 1 (the itinerary driver) consumes (draw ...); Phase 2 (the
; affordance-resolution pass) consumes (afford ...).
;
; Form:
;   (place <building-kind>
;     (capacity <N>)                       ; max occupants; 0/omitted = default crowd cap
;     (afford <event> <precond> <rate>)    ; one per affordance the place hosts
;     (draw   <band> <weight> [selector])) ; one per reason an agent comes here
;
;   <event>    an affordance / event-template id. Aligned to existing hsim
;              events where one exists (gossip, catch_up, confide, court,
;              family_dinner, affair_rendezvous, outdo, patronage, ...); Phase 2
;              binds each id to its event. NOT validated here.
;   <precond>  the co-presence precondition the affordance needs against the
;              venue's occupant set:
;                solo        no co-presence needed (worship, browse, work)
;                pair        >= 2 occupants present (gossip, brawl, insult)
;                lover       a lover of the actor is present (affair_rendezvous)
;                cohabitant  a co-resident is present (family_dinner, poison)
;                rival       a rival is present (outdo, ambition)
;                staff       a staff member is present (purchase, buy_weapon)
;   <rate>     per-occasion base probability [0,1]. UNCALIBRATED - these are
;              initial estimates; Phase 2 owns tuning against realized
;              opportunity frequencies (the sampled-day rescaling, Section 4.2).
;   <band>     dawn | morning | midday | afternoon | evening | night
;              (the canonical merlin::t_day_band names; the working day is
;              represented by midday).
;   <selector> a free disposition / class tag the Phase 1 driver maps to NPC
;              attributes. Vocabulary used below: sociable, pious, gentry,
;              working_class, club_member, enthusiast, suitor. "" / omitted =
;              draws anyone.
;
; Place kinds are matched by EXACT name; the consumer resolves the kind
; hierarchy (a `cottage` building falls back to `residential_building`), so
; shared home affordances are authored once at `residential_building` and
; venue-specific ones at the leaf. Workplaces carry no (draw ...) - they are
; reached by the employment routine (Phase 1), not by attraction. Outdoor crime
; venues (the spec's back_alley -> mug/ambush) await an outdoor place kind in
; Spaces.mon; not authorable yet. ';' or '#' line comments.
; ----------------------------------------------------------------------------

;; --- Home (any residence): the domestic + intimate affordances. Reached by
;;     routine, so no (draw ...). poison is the cohabiting crime opportunity the
;;     Phase 2 crime migration will bind. ---
(place residential_building
  (afford family_dinner    cohabitant 0.40)
  (afford domestic_quarrel cohabitant 0.06)
  (afford confide          pair       0.10)
  (afford affair_rendezvous lover     0.18)
  (afford gossip           pair       0.10)
  (afford poison           cohabitant 0.01))

;; --- Leisure / social venues ---
(place pub
  (afford drink     solo 0.50)
  (afford gossip    pair 0.30)
  (afford catch_up  pair 0.15)
  (afford court     pair 0.08)
  (afford gamble    pair 0.10)
  (afford insult    pair 0.05)
  (afford brawl     pair 0.04)
  (draw evening 1.00 sociable)
  (draw midday   0.25 working_class))

(place social_clubhouse
  (afford gossip    pair  0.30)
  (afford gamble    pair  0.15)
  (afford confide   pair  0.08)
  (afford patronage pair  0.05)
  (afford recruit   pair  0.04)
  (afford outdo     rival 0.10)
  (draw evening 1.00 club_member)
  (draw night   0.40 club_member))

(place athletic_clubhouse
  (afford club_sport pair  0.40)
  (afford gossip     pair  0.20)
  (afford outdo      rival 0.12)
  (draw midday   0.60 club_member)
  (draw evening 0.80 club_member))

(place restaurant
  (afford court    pair 0.15)
  (afford catch_up pair 0.20)
  (afford gossip   pair 0.15)
  (draw evening 0.70 gentry))

(place theatre
  (afford court    pair 0.12)
  (afford catch_up pair 0.10)
  (afford gossip   pair 0.15)
  (draw evening 0.70 gentry))

;; --- Retail / services: errand-driven (Phase 3), so light (draw ...) only.
;;     The shop is where weapon purchase + general buying happen; the barbershop
;;     is the iconic gossip counter. ---
(place shop
  (afford purchase   staff 0.30)
  (afford buy_weapon staff 0.05)
  (afford browse     solo  0.20)
  (afford gossip     pair  0.12)
  (draw midday 0.30))

(place barbershop
  (afford purchase staff 0.30)
  (afford gossip   pair  0.25)
  (draw midday 0.25 sociable))

(place bank
  (afford deposit staff 0.30)
  (afford borrow  staff 0.05)
  (draw midday 0.20))

;; --- Civic / cultural venues (govt-bootstrapped; the interest activity lane's
;;     destinations). Enthusiasts pursue their interest here. ---
(place church
  (afford worship solo 0.60)
  (afford gossip  pair 0.20)
  (afford confide pair 0.08)
  (afford wed     pair 0.02)
  (draw dawn 1.00 pious))

(place library
  (afford study  solo 0.40)
  (afford gossip pair 0.08)
  (draw midday   0.40 enthusiast)
  (draw evening 0.30 enthusiast))

(place museum
  (afford browse   solo 0.40)
  (afford catch_up pair 0.10)
  (draw midday 0.40 enthusiast))

(place meeting_hall
  (afford assembly pair 0.30)
  (afford gossip   pair 0.20)
  (draw evening 0.40))

(place sports_ground
  (afford spectate   pair  0.40)
  (afford club_sport pair  0.25)
  (afford gossip     pair  0.20)
  (afford outdo      rival 0.06)
  (draw midday   0.40 enthusiast)
  (draw evening 0.50 enthusiast))

(place hotel
  (afford affair_rendezvous lover 0.30)
  (afford gossip            pair  0.10))

;; --- Workplaces: reached by the employment routine, so no (draw ...). work is
;;     the solo routine affordance; gossip + ambition are the incidental social
;;     ones a shared workplace hosts. ---
(place office
  (afford work     solo  0.80)
  (afford gossip   pair  0.20)
  (afford ambition rival 0.04))

(place factory
  (afford work   solo 0.80)
  (afford gossip pair 0.15))

(place warehouse
  (afford work solo 0.80))

(place newspaper
  (afford work   solo 0.80)
  (afford gossip pair 0.15))

(place school
  (afford study  solo 0.50)
  (afford work   solo 0.40)
  (afford gossip pair 0.15))

(place hospital
  (afford work       solo 0.60)
  (afford convalesce solo 0.10))

(place police_station
  (afford work        solo  0.60)
  (afford file_report staff 0.10))
