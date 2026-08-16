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
; {@self ACQUIRE} desire once a year; the routing
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
;   buy_home        : yearly timer - seeker gate -> mint the {@self ACQUIRE} desire.
;   buy_home_go     : hold the desire, register unread, knows an agency, not there -> travel.
;   buy_home_read   : hold the desire, register unread, AT a known agency -> read it.
;   buy_home_find   : hold the desire, register unread, knows NO agency -> orient (learn one).
;   choose_home     : listings learned -> pick nicest affordable UNCLAIMED, promote the buy.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
(include "../../../macros/tunables.hs")

(npc-think buy_home
  ; ANNUAL: a yearly timer mints the standing acquire desire once per year (the market
  ; then works it through buy_home_go / find / choose_home). (begin-goal) is idempotent
  ; so an annual re-mint is a no-op.
  (cooldown 1 y)
  ; Seeker: an UNMARRIED adult who has a home but neither owns nor leases it (an
  ; adult child still in the natal / inherited home). The unmarried gate keeps the
  ; market from re-separating a couple housed in a spouse's owned / leased home -
  ; the marital-home case the old C++ market special-cased. FULLY CACHED: the
  ; unmarried gate is a self-gate filter, and ?h is a cached role whose filters
  ; all test the SAME candidate (his home, unowned, unleased) - a non-seeker
  ; carries an empty set and skips without any live belief scan.
  (role @self (adult @self)
              (not {@self spouse ?}))
  (role ?h {@self home ?h}
           (not {@self own ?h})
           (not {?h tenant @self}))
  (utility errand 100)
  (effects       (begin-goal {@self ACQUIRE}))
  (cease-effects (end-goal   {@self ACQUIRE})))
