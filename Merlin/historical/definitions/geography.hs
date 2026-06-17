; ----------------------------------------------------------------------------
; geography.cfg
;
; St-Revier in 1700 expressed in the LISP-style hsim grammar (see
; Merlin/Src/Lib/hsim/geography.h). Each top-level form is one of:
;
;   (area <id>)
;   (road <id> <area-id> "Street Name")
;   (template <name> (kind <ontology-kind>) (class <lower|middle|upper>)
;                          (extras (key value) ...))
;   (make_entity <template> (parent <area-or-road-id>) (id <override>)
;                           (coord x y z) (rot qx qy qz qw)
;                           (extras (k v) ...))
;   (make_entity_along <template> <road-id> <from-int> <to-int>
;                                (extras (k v) ...))
;
; The materialiser (hsim_world_setup) creates one Merlin Env entity per
; area, road, and instantiated entity (mx_make_entity). Templates declare
; reusable kind+class; instances can override per-entry. extras carry
; era_min, era_max, business flag, etc, parsed by downstream consumers.
; ----------------------------------------------------------------------------

;; ---- Templates ----
;; "estate" entries represent a manor on its own grounds. The building
;; entity is the manor; the grounds are modeled by the parent area.
(template estate    (kind [k manor])     (class upper))
(template townhouse (kind [k townhouse]) (class middle))
(template tenement  (kind [k tenement])  (class lower))
(template cottage   (kind [k cottage])   (class lower))
(template farmhouse (kind [k farmhouse]) (class lower))
(template chapel    (kind [k chapel])    (class middle))

;; Businesses are physical commercial buildings (kind in Objects.mon)
;; with a `business` extra naming the company kind from Concepts.mon.
;; The historical sim treats the business extra as the org identity for
;; occupation assignment + employment beliefs. We name physical kinds
;; with their parent path so the resolver disambiguates against
;; same-named org kinds in Concepts.mon (e.g. "factory" exists both as
;; a physical structure and as a business org).
(template shipping_agent  (kind [k commercial_building office])    (class middle) (extras (business shipping_agent)))
(template factory         (kind [k commercial_building factory])   (class middle) (extras (business factory)))
(template newspaper       (kind [k commercial_building newspaper]) (class middle) (extras (business newspaper)))
(template pub             (kind [k commercial_building pub])       (class middle) (extras (business pub)))
(template church          (kind [k commercial_building church])    (class middle) (extras (business church)))
(template bank            (kind [k commercial_building bank])      (class middle) (extras (business bank)))
(template grocer          (kind [k commercial_building shop])      (class middle) (extras (business grocer)))
(template apothecary      (kind [k commercial_building shop])      (class middle) (extras (business apothecary)))
(template solicitor_firm  (kind [k commercial_building office])    (class middle) (extras (business solicitor_firm)))
(template house_agency    (kind [k commercial_building office])    (class middle) (extras (business house_agency)))
(template private_school  (kind [k commercial_building school])    (class middle) (extras (business private_school)))
(template antiques_shop   (kind [k commercial_building shop])      (class middle) (extras (business antiques_shop)))

;; Public-good institution buildings. The org-bootstrap matches an org to a
;; building by ontology kind (commercial_building hospital / office / school).
(template hospital         (kind [k commercial_building hospital]) (class middle))
(template post_office      (kind [k commercial_building office])   (class middle))
(template state_school     (kind [k commercial_building school])   (class middle))
(template land_registry    (kind [k commercial_building office])   (class middle))
(template company_registry (kind [k commercial_building office])   (class middle))

;; ============================================================================
;; Area: Port Christie
;; ============================================================================
(area port_christie)
(road victoria_street port_christie "Victoria Street")
(road dock_road       port_christie "Dock Road")
(road harbour_lane    port_christie "Harbour Lane")
(road market_street   port_christie "Market Street")
(road chapel_row      port_christie "Chapel Row")

(make_entity estate    (id blackthorne_estate)  (parent port_christie))
(make_entity estate    (id ashworth_house)      (parent port_christie))
(make_entity townhouse (id duval_townhouse)     (parent victoria_street))
(make_entity townhouse (id whitfield_townhouse) (parent market_street))
(make_entity chapel    (id town_chapel)         (parent chapel_row))

;; Residential bulk for Port Christie. Numbering is per road; ids are
;; <template>_<road>_<n> downstream so collisions are impossible.
(make_entity_along townhouse victoria_street 1 60)
(make_entity_along townhouse market_street   1 60)
(make_entity_along tenement  harbour_lane    1 60)
(make_entity_along tenement  dock_road       1 50)
(make_entity_along cottage   chapel_row      1 30)

(make_entity shipping_agent (id harbour_dock)              (parent dock_road))
(make_entity factory        (id weaving_mill)              (parent dock_road)        (extras (era_min 1830)))
(make_entity newspaper      (id port_christie_chronicle)   (parent victoria_street)  (extras (era_min 1750)))
(make_entity pub            (id the_lion_inn)              (parent market_street))
(make_entity church         (id saint_michaels)            (parent chapel_row))
(make_entity bank           (id port_christie_bank)        (parent market_street)    (extras (era_min 1780)))
(make_entity grocer         (id victoria_grocer)           (parent victoria_street))
(make_entity apothecary     (id hawthorne_apothecary)      (parent market_street))
(make_entity solicitor_firm (id prentice_solicitors)       (parent victoria_street)  (extras (era_min 1750)))
(make_entity house_agency   (id haven_house_agency)        (parent market_street)    (extras (era_min 1820)))

;; Public-good institutions of Port Christie.
(make_entity hospital         (id port_christie_hospital)  (parent victoria_street))
(make_entity post_office      (id port_christie_post)      (parent market_street))
(make_entity state_school     (id port_christie_school)    (parent victoria_street))
(make_entity land_registry    (id port_christie_registry)  (parent market_street))
(make_entity company_registry (id companies_house)         (parent victoria_street)  (extras (era_min 1840)))

;; ============================================================================
;; Area: Valette
;; ============================================================================
(area valette)
(road south_promenade valette "South Promenade")
(road kings_road      valette "Kings Road")
(road mill_lane       valette "Mill Lane")

(make_entity estate    (id chevalier_estate)   (parent valette))

;; Residential bulk for Valette.
(make_entity_along townhouse south_promenade 1 50)
(make_entity_along townhouse kings_road      1 50)
(make_entity_along tenement  mill_lane       1 50)

(make_entity factory        (id valette_mill)    (parent mill_lane)        (extras (era_min 1840)))
(make_entity pub            (id kingsroad_pub)   (parent kings_road))
(make_entity grocer         (id valette_grocer)  (parent kings_road))
(make_entity church         (id saint_andrews)   (parent south_promenade))
(make_entity private_school (id valette_school)  (parent south_promenade)  (extras (era_min 1810)))

;; ============================================================================
;; Area: Haven
;; ============================================================================
(area haven)
(road cliff_road      haven "Cliff Road")
(road fishermans_walk haven "Fishermans Walk")
(road st_marys_road   haven "St Marys Road")

(make_entity estate  (id haven_manor)        (parent haven))
(make_entity cottage (id carrigan_cottage)   (parent fishermans_walk))
(make_entity cottage (id oconnell_cottage)   (parent fishermans_walk))

;; ============================================================================
;; Outlying dwellings - isolated farms and cottages scattered BETWEEN the
;; settlements. Explicit world coords keep each one well clear of every
;; road cluster and of each other, so the bootstrap isolation pass stamps
;; them isolated=1: the remote premises a burglar can break into at night
;; with no neighbors to see (the theft calculus's preferred steal sources).
;; ============================================================================
(make_entity farmhouse (id thornfield_farm)    (parent port_christie) (coord -1500 5  600))
(make_entity farmhouse (id mosshollow_farm)    (parent valette)       (coord     0 5 -800))
(make_entity cottage   (id heath_cottage)      (parent valette)       (coord  -200 5  900))
(make_entity farmhouse (id greywether_farm)    (parent haven)         (coord  1500 5 -500))
(make_entity cottage   (id lighthouse_cottage) (parent haven)         (coord  1700 5  700))

;; Residential bulk for Haven (smallest of the three areas).
(make_entity_along cottage   cliff_road      1 60)
(make_entity_along cottage   fishermans_walk 1 50)
(make_entity_along townhouse st_marys_road   1 30)

(make_entity pub           (id haven_pub)     (parent fishermans_walk))
(make_entity church        (id saint_marys)   (parent st_marys_road))
(make_entity grocer        (id haven_grocer)  (parent fishermans_walk))
(make_entity antiques_shop (id haven_smithy)  (parent st_marys_road))

;; ============================================================================
;; Exterior amenity + remote wilds (Section 4.12). Authored exterior_space
;; entities: their OBB is a co-presence region just like a room. Placement is
;; deliberate - the parks sit in town fronting a street; the wilds sit well
;; clear of every settlement, the isolated scenes a transit-kill needs.
;;   (feature <kind> (name "..") (at x y z) (extent hx hy hz) [(road id) (number n)])
;; Parks front a street (an address); wilds are name-only.
;; ============================================================================
(feature park   (name "Victoria Park")      (at -2100  2  220) (extent  55  2  55) (road victoria_street))
(feature park   (name "Kings Gardens")      (at  -600  2  230) (extent  45  2  45) (road kings_road))
(feature park   (name "The Esplanade")      (at   900  2  130) (extent  50  2  50) (road cliff_road))

(feature forest (name "Blackwood Forest")   (at -3300  6    0) (extent 150  6 150))
(feature moor   (name "Gallows Moor")       (at -1500  6 1650) (extent 160  6 160))
(feature meadow (name "Julie's Meadow")     (at     0  5 -1450) (extent  90  5  90))
(feature bluff  (name "Raven's Bluff")      (at  1700 12 -1100) (extent  45 12  70))
(feature cliff  (name "St Brendan's Cliff") (at  1500 14 1300) (extent  35 14  90))
(feature moor   (name "Carrick Moor")       (at -2500  6 -1250) (extent 150  6 150))
(feature forest (name "Eastmoor Wood")      (at  2000  6  350) (extent 110  6 110))
