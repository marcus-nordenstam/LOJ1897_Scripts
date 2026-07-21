; ----------------------------------------------------------------------------
; buy_home - the DEMAND side of the property market (per-NPC replacement for the
; omniscient world-act/housing_market.hs buy stage). A seeker LEARNS what is for
; sale by reading the agent's register, then buys the nicest dwelling he can
; afford by a per-NPC roulette. This REPLACES the old global "the wealthiest
; claim the nicest" optimiser - no seeker knows a listing he has not read, and
; the winner is drawn (value-weighted), not sorted.
;
; A seeker is an adult who lives in a home he neither owns nor leases (an adult
; child still in the natal / inherited home). A yearly timer mints the standing
; {@self acquire} desire once a year; the routing
; thinks walk him to a house agency and read the FOR-SALE register - the KNOWLEDGE
; CHANNEL that mints his {@self for_sale ?b} beliefs (reuse of the foundation
; read-public-register macro). Only once he KNOWS listings does choose_home cast a
; dwelling and promote the purchase act (buy_home_act.hs).
;
; Routing mirrors the worship lane's three-case structure so the market never goes
; dormant merely because @self has not yet learned which orgs are house agencies:
;   AT a known agency's office   -> buy_home_read (promote the register read).
;   KNOWS an agency, not there   -> buy_home_go   (travel to its office).
;   KNOWS no agency at all       -> buy_home_find (route to the incorporations
;     register via the orient lane; reading it mints his {?agency isa [k org
;     house_agency]} beliefs so buy_home_go can then fire).
;
;   buy_home        : yearly timer - seeker gate -> mint the {@self acquire} desire.
;   buy_home_go     : hold the desire, register unread, knows an agency, not there -> travel.
;   buy_home_read   : hold the desire, register unread, AT a known agency -> read it.
;   buy_home_find   : hold the desire, register unread, knows NO agency -> orient (learn one).
;   choose_home     : listings learned -> pick nicest affordable UNCLAIMED, promote the buy.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/tunables.hs")

; dwelling-value - the kind -> tier ranking (nicest first), mirroring the C++
; building_value the old market sorted on. CONTENT, so it lives here as a local
; macro. is-a resolves the dwelling's kind (mental object, else the env entity),
; so a listing read off a [building]-only document still ranks. 0 = not a dwelling.
(define-macro dwelling-value (?b)
  (if (is-a ?b [k manor])     5
  (if (is-a ?b [k townhouse]) 4
  (if (is-a ?b [k farmhouse]) 3
  (if (is-a ?b [k chapel])    2
  (if (is-a ?b [k rowhouse])  1
      0))))))

(npc-think buy_home
  ; ANNUAL: a yearly timer mints the standing acquire desire once per year (the market
  ; then works it through buy_home_go / find / choose_home). No cadence marker - the
  ; (schedule ...) IS the cadence; (begin-goal) is idempotent so an annual re-mint is a no-op.
  (schedule cooldown 1 y)
  (if-blocked hold)
  ; Seeker: an UNMARRIED adult who has a home but neither owns nor leases it (an
  ; adult child still in the natal / inherited home). The unmarried gate keeps the
  ; market from re-separating a couple housed in a spouse's owned / leased home -
  ; the marital-home case the old C++ market special-cased. FULLY CACHED: the
  ; unmarried gate is a self-gate filter, and ?h is a cached role whose filters
  ; all test the SAME candidate (his home, unowned, unleased) - a non-seeker
  ; carries an empty set and skips without any live belief scan.
  (role @self (adult @self)
              (not (believes {@self spouse ?})))
  (role ?h (believes {@self home ?h})
           (not (believes {@self own ?h}))
           (not (believes {?h tenant @self})))
  (effects       (begin-goal {@self acquire}))
  (cease-effects (end-goal   {@self acquire})))

; CASE B - knows a house agency, register unread, not at its office: travel there.
; Its articles name the office (articles-building). Inherits the acquire drive.
(npc-think buy_home_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self acquire})
  (role @self (not (believes {@self for_sale ?})))   ; register unread - cached
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (not (in-building ?venue))))
  (utility 35)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

; CASE A - AT a known agency, register still unread: promote the read act (the
; knowledge channel).
(npc-think buy_home_read
  (schedule on-commit)
  (goal {@self acquire})
  (role @self (not (believes {@self for_sale ?})))   ; register unread - cached
  (role ?agency (believes {?agency isa [k org house_agency]})
                (believes {?agency record ?art}))   ; existence cached, ?art binds at fire
  (when (and (articles-building ?art ?venue)
             (in-building ?venue)))
  (utility 35)
  (effects       (begin-goal {@self read_listings}))
  (cease-effects (end-goal   {@self read_listings})))

; CASE C - register unread and @self knows NO house agency at all: consult the
; parish incorporations register (the orient lane, orient_errand.hs), which mints
; a mental org object + {?org isa ...} belief for EVERY org in town - the only
; honest channel by which an org's identity is learned (co-presence at an office
; teaches acquaintances, not that the office IS a house agency). The instant a
; house_agency is learned the (no-role ...) fills, this stops, and buy_home_go
; takes over. (no-role [k org house_agency]) reads the SAME per-mind object cache
; buy_home_go's positive role populates ([k <kind>] is sugar for {isa [k <kind>]}).
(npc-think buy_home_find
  (schedule on-commit)
  (goal {@self acquire})
  (no-role [k org house_agency])
  (role @self (not (believes {@self for_sale ?})))   ; register unread - cached
  (utility 30)
  (effects       (begin-goal {@self orient}))
  (cease-effects (end-goal   {@self orient})))

; Listings learned: cast the nicest dwelling he can AFFORD and that no rival has
; CLAIMED, by a value-weighted roulette (per-NPC choice), and promote the purchase.
; A claimed dwelling scores 0 (dropped from the draw); the (when) also hard-blocks
; committing to one, so two seekers in the same window cannot both buy it. On
; commit @self posts his OWN claim (pub-bb-post) so a rival defers; the claim is
; re-posted each cont-fire and self-clears by ttl once he stops (see tunables.hs).
; The affordability gate is his OWN wealth vs the tier cost (0.15 per tier - the
; C++ k_buy_wealth_per_value).
(npc-think choose_home
  (schedule on-changed {@self for_sale ?})
  (goal {@self acquire})
  (role ?dwell (believes {@self for_sale ?dwell})
               (select (score (* (dwelling-value ?dwell)
                                 (if (pub-bb-none ?dwell claimed) 1 0)))
                       (policy roulette)))
  (when (and (>= (target {@self wealth}) (* (dwelling-value ?dwell) 0.15))
             (pub-bb-none ?dwell claimed)))
  (utility 45)
  (effects
    (pub-bb-post ?dwell claimed (claim_marker_ttl_cycles))
    (begin-goal {@self buy_home ?dwell}))
  (cease-effects (end-goal {@self buy_home ?dwell})))
