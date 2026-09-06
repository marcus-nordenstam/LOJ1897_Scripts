; ----------------------------------------------------------------------------
; buy-home - the DEMAND side of the property market (per-NPC replacement for the
; omniscient world-act/housing_market.hs buy stage). A seeker LEARNS what is for
; sale by reading the agent's register, then buys the nicest dwelling he can
; afford by a per-NPC roulette: no seeker knows a listing he has not read, and
; the winner is drawn (value-weighted), not sorted.
;
; A seeker is an adult who lives in a home he neither owns nor leases (an adult
; child still in the natal / inherited home). A yearly timer mints the standing
; {@self acquire} desire once a year; the routing
; thinks walk him to a house agency and read the FOR-SALE register - the KNOWLEDGE
; CHANNEL that mints his {@self for-sale ?b} beliefs (reuse of the foundation
; read-public-register macro). Only once he KNOWS listings does choose_home cast a
; dwelling and promote the purchase act (buy_home_act.hs).
;
; Routing mirrors the worship lane's three-case structure so the market never goes
; dormant merely because @self has not yet learned which orgs are house agencies:
;   AT a known agency's office   -> buy_home_read (promote the register read).
;   KNOWS an agency, not there   -> buy_home_go   (travel to its office).
;   KNOWS no agency at all       -> buy_home_find (route to the incorporations
;     register via the orient lane; reading it mints his {?agency isa [k org
;     house-agency]} beliefs so buy_home_go can then fire).
;
;   buy-home        : yearly timer - seeker gate -> mint the {@self acquire} desire.
;   buy_home_go     : hold the desire, register unread, knows an agency, not there -> travel.
;   buy_home_read   : hold the desire, register unread, AT a known agency -> read it.
;   buy_home_find   : hold the desire, register unread, knows NO agency -> orient (learn one).
;   choose_home     : listings learned -> pick nicest affordable UNCLAIMED, promote the buy.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")
(include "../../../macros/tunables.mc")

; dwelling-value - the kind -> tier ranking (nicest first), mirroring the C++
; building_value the old market sorted on. CONTENT, so it lives here as a local
; macro. is-a resolves the dwelling's kind (mental object, else the env entity),
; so a listing read off a [building]-only document still ranks. 0 = not a dwelling.
(define-macro dwelling-value (?b)
  (if (is-a ?b [k manor])     (then 5)
  (else (if (is-a ?b [k townhouse]) (then 4)
  (else (if (is-a ?b [k farmhouse]) (then 3)
  (else (if (is-a ?b [k chapel])    (then 2)
  (else (if (is-a ?b [k rowhouse])  (then 1)
      (else 0)))))))))))

; CASE B - knows a house agency, register unread, not at its office: travel there.
; Its articles name the office (articles-building). Inherits the acquire drive.
(npc-think buy_home_go
  (goal {@self acquire})
  (role @self -{? availability [k for-sale]})   ; no listing read yet - cached
  ; The office is the agency's OWN workplace belief. The old spelling bound ?art off
  ; {?agency record ?art} and then had (articles-building ?art ?venue) walk BACK from the
  ; articles to the org that records them - which is ?agency - purely to read its workplace.
  (role ?agency {?agency isa [k org house-agency]}
                {?agency workplace ?venue}
                (not (spatial @self building ?venue)))
  (effects (maintain-proposal {@self enter ?venue})))

; CASE A - AT a known agency, register still unread: PROPOSE the read act (the
; knowledge channel). act_body_purification: this rung already gates on the
; readiness (at the agency, register unread), so it IS the terminal - it proposes
; the read directly (its /caused_by is the {@self acquire} desire it gates on). Once the
; read forms the {@self for-sale ?} beliefs, the unread self-gate empties and the
; rung stops.
(npc-think buy_home_read
  (goal {@self acquire})
  (role @self -{? availability [k for-sale]})   ; no listing read yet - cached
  (role ?agency {?agency isa [k org house-agency]}
                {?agency workplace ?venue}
                (spatial @self building ?venue))
  (role ?reg [k for-sale-listings])
  (effects (maintain-proposal {@self read-listings ?reg})))

; CASE C - register unread and @self knows NO house agency at all: consult the
; parish incorporations register (the orient lane, orient_errand.hs), which mints
; a mental org object + {?org isa ...} belief for EVERY org in town - the only
; honest channel by which an org's identity is learned (co-presence at an office
; teaches acquaintances, not that the office IS a house agency). The instant a
; house-agency is learned the (no-role ...) fills, this stops, and buy_home_go
; takes over. (no-role [k org house-agency]) reads the SAME per-mind object cache
; buy_home_go's positive role populates ([k <kind>] is sugar for {isa [k <kind>]}).
(npc-think buy_home_find
  (goal {@self acquire})
  (no-role [k org house-agency])
  (role @self -{? availability [k for-sale]})   ; no listing read yet - cached
  (utility errand)
  (effects       (begin-goal {@self ORIENT}))
  (cease-effects (end-goal   {@self ORIENT})))

; Listings learned: cast the nicest dwelling he can AFFORD and that no rival has
; CLAIMED, by a value-weighted roulette (per-NPC choice), and promote the purchase.
; A claimed dwelling scores 0 (dropped from the draw); the (when) also hard-blocks
; committing to one, so two seekers in the same window cannot both buy it. On
; commit @self posts his OWN claim (pub-bb-post) so a rival defers; the claim is
; refreshed while he keeps choosing and self-clears by ttl once he stops (see tunables.hs).
; The affordability gate is his OWN wealth vs the tier cost (0.15 per tier - the
; C++ k_buy_wealth_per_value).
(npc-think choose_home
  (goal {@self acquire})
  (role @self {@self wealth ?wealth})
  (role ?dwell {?dwell availability [k for-sale]}
               (select (score (* (dwelling-value ?dwell)
                                 (if (bb-public-none ?dwell claimed) (then 1) (else 0))))
                       (policy roulette)))
  (when (and (>= ?wealth (* (dwelling-value ?dwell) 0.15))
             (bb-public-none ?dwell claimed)))
  (utility errand)
  (effects
    (bb-public-maintain ?dwell claimed @self (claim_marker_ttl_cycles))
    (begin-goal {@self buy-home ?dwell}))
  (cease-effects (end-goal {@self buy-home ?dwell})))

; TERMINAL step (act_body_purification): PROMOTE the buy-home TASK off the latched
; {@self buy-home ?dwell} goal choose_home minted (the chosen dwelling). Kept
; separate from choose_home because that rung roulettes + posts the claim and must
; NOT re-roll the chosen dwelling; this rung proposes the already-chosen dwelling
; until the task concludes (its take_up rung drops {?dwell availability for-sale},
; ending the goal). The buy-home task itself re-validates against @self's read-in
; availability belief, so a stale propose is a safe no-op.
(npc-think buy_home_do
  (goal {@self buy-home ?dwell})
  (effects (maintain-proposal {@self buy-home ?dwell})))
