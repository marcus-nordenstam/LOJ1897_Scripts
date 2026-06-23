; ----------------------------------------------------------------------------
; birthday_party (npc-think). The recurring news-exchange that drives long-tail
; gossip: once a year a share of NPCs hold a catch-up, and each pair of (host,
; friend-of-host) exchanges the news of the past year. Ceremonies (betrothal /
; wedding / christening) carry milestones to a bounded guest list; this carries
; everything else, lossily and slowly.
;
; (exchange-news ?host ?guest) is symmetric and uses a fixed one-year lookback
; window, matching this event's annual cadence. It refreshes each party's profile
; of the other and relays their recent spouse / child / friend news - so a guest
; comes to know of people they have never met, through the host.
;
; A mental change (profiles refresh, news lands), so npc-think. RELATIONAL: the
; guest is any friend of the host. The co-present gate the place-lane draft tried
; was reverted - a specific host/friend pair rarely coincides by chance, so
; gating on physical co-presence collapsed the event; the friend tie IS the
; gathering's reach. Fired by the per-NPC emergent pass MONTHLY, so the host
; (chance) is /12 (the *0.0667 wrapper) to hold the old annual party volume.
;
; Topology: ?host is enumerated (gated by chance); ?guest is recovered as any
; person the host holds a {friend} belief toward. The friend filter already
; excludes infants (no friends), so no age gate is needed.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event birthday_party
  (sim-window-start)
  (nl         "@self and ?guest exchange news")
  (rng-stream friendships)

  (roles
    ;; @self is the host. PR-A-8 substrate gate: the canonical host motivation is a
    ;; social life_aim (belonging / respectability - the aims that prize community
    ;; visibility) OR being a parent (parties for one's child). The chance is
    ;; multiplicative on enthusiasm so outgoing hosts engage more than withdrawn
    ;; ones, /12'd to the monthly window cadence, rolled once per host per window.
    (role @self (template any_human)
                (or (believes {@self life_aim belonging_aim})
                    (believes {@self life_aim respectability_aim})
                    (believes {@self identity parent_role}))
                (chance (* 0.0667 (attr @self enthusiasm))))
    (role ?guest (template any_human)
                 (not (= ?guest @self))
                 (believes {@self friend ?guest})))

  (effects
    (exchange-news @self ?guest)
    (log _birthday_party @self)))
