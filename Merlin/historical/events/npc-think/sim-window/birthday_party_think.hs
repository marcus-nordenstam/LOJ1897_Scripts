; ----------------------------------------------------------------------------
; birthday_party (npc-think). The recurring news-exchange that drives long-tail
; gossip: once a year a share of NPCs hold a catch-up, and each pair of (host,
; friend-of-host) exchanges the news of the past year. Ceremonies (betrothal /
; wedding / christening) carry milestones to a bounded guest list; this carries
; everything else, lossily and slowly.
;
; The host SAYS their own recent news aloud at the gathering: (tell (top-untold-
; belief @self _ @self ...)) broadcasts the freshest spouse / fiancee / lover /
; child fact they have not already announced, to whoever is co-present. A guest
; comes to know of people through the host by hearing it - and self-news cascades
; onward as ordinary gossip. (The old telepathic two-way (exchange-news) is gone;
; the reciprocal half is each guest's OWN catch_up / party.)
;
; An ACT (tell), but kept here as an occasion (the host life_aim / parent gate is
; the party framing; the friend tie is the guest list). Fired by the per-NPC
; emergent pass MONTHLY, so the host (chance) is /12 (the *0.0667 wrapper) to hold
; the old annual party volume.
;
; Topology: ?host is enumerated (gated by chance); ?guest is recovered as any
; person the host holds a {friend} belief toward. The friend filter already
; excludes infants (no friends), so no age gate is needed.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think birthday_party
  (sim-window-think)
  (rng-stream friendships)

  ;; @self is the host. PR-A-8 substrate gate: the canonical host motivation is a
  ;; social life_aim (belonging / respectability - the aims that prize community
  ;; visibility) OR being a parent (parties for one's child). The enthusiasm-scaled
  ;; chance gate moved to (when) below (non-belief filter).
  (role @self (any_human @self)
              (or (believes {@self life_aim belonging_aim})
                  (believes {@self life_aim respectability_aim})
                  (believes {@self identity parent_role})))
  (role ?guest (any_human ?guest)
               (not (= ?guest @self))
               (believes {@self friend ?guest}))

  ;; Moved from the @self role (non-belief): enthusiasm-scaled chance, multiplicative
  ;; so outgoing hosts engage more than withdrawn ones, /12'd to the monthly window
  ;; cadence, rolled once per host per window.
  (when (chance (* 0.0667 (attr @self enthusiasm))))

  (cont-fire-effects
    ; Broadcast the host's own freshest untold news to the co-present gathering.
    ; The host airs one piece of their own news not yet told (see catch_up_act for
    ; the for-each-belief + (utterable-msg)-dedup shape).
    (for-each-belief ?fact {@self spouse|fiancee|lover|child ?tgt}
      (do
        (bind (utterable-msg ?fact) ?msg)
        (if (not (believes {@self SAY ?msg _}))
            (do (tell ?fact) (break)))))
    ))
