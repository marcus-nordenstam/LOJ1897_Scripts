; ----------------------------------------------------------------------------
; Birthday party. The recurring gathering that drives gossip: once a year a
; share of NPCs host a catch-up, and each pair of (host, friend-of-host)
; exchanges the news of the past year. This is the long-tail propagation
; channel - ceremonies (betrothal / wedding / christening) carry milestones to
; a bounded guest list; gossip carries everything else, lossily and slowly.
;
; (exchange-news ?host ?guest) is symmetric and uses a fixed one-year lookback
; window, matching this event's annual cadence. It refreshes each party's
; profile of the other and relays their recent spouse / child / friend news -
; so a guest comes to know of people they have never met, through the host.
;
; Topology: ?host is enumerated (gated by chance); ?guest is recovered as any
; person the host holds a {friend} belief toward. The friend filter already
; excludes infants (no friends), so no age gate is needed.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event birthday_party
  (nl         "?host and ?guest exchange news")
  (kind       _birthday_party)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the residential_building
  ; `birthday_party` affordance among the gathered guests (run_gatherings does
  ; the invite-and-travel; place-lane, suppressed from the DES).
  (band      evening)
  (rng-stream friendships)

  (roles
    ;; PR-A-8 substrate gate: hosts have a social motivation - their
    ;; life_aim is belonging_aim or respectability_aim (the two aims
    ;; that prize community visibility), OR they're a parent (parties
    ;; for one's child). Eliminates the chance-primary pick. The chance
    ;; is multiplicative on enthusiasm so outgoing hosts engage more
    ;; than withdrawn ones - smooth trait gradient on top of the
    ;; substrate gate.
    ;; PR-A-8 substrate gate: the canonical host motivation is being a
    ;; parent ({@self identity parent_role}, derived by
    ;; classify_identities). The plan also calls out life_aim=belonging
    ;; / respectability as alternative motivations - those clauses are
    ;; deferred pending an investigation into why (situation life_aim)
    ;; comparisons against kind atoms fail in role filters (the
    ;; comparator's atom-to-kind resolution path needs a closer look).
    ;; For V1, parent identity is the substrate gate; enthusiasm
    ;; amplifies the chance so outgoing parents engage more than
    ;; withdrawn ones.
    (role ?host  (template any_human)
                 (or (= (situation ?self life_aim) belonging_aim)
                     (= (situation ?self life_aim) respectability_aim)
                     (believes ?self {@self identity parent_role}))
                 (chance (* 0.80 (attr ?self enthusiasm))))
    (role ?guest (template any_human)
                 (not (= ?self ?host))
                 (believes ?host {@self friend ?guest})
                 ; Place model: you celebrate with the friends actually present.
                 ; run_gatherings does the invite-and-travel (the host's friends
                 ; leave their routine and come to the host's home this evening),
                 ; and the residential_building `birthday_party` affordance fires
                 ; this among them - so the guest list is the gathered circle.
                 (co-present ?host ?guest)))

  (effects
    (exchange-news ?host ?guest)
    (log _birthday_party ?host)))
