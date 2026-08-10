; ----------------------------------------------------------------------------
; birthday_party (npc-think). The recurring news-exchange that drives long-tail
; gossip: once a year a share of NPCs hold a catch-up, and each pair of (host,
; friend-of-host) exchanges the news of the past year. Ceremonies (betrothal /
; wedding / christening) carry milestones to a bounded guest list; this carries
; everything else, lossily and slowly.
;
; The host TELLS each co-present friend the freshest spouse / fiancee / lover /
; child fact that guest has not already heard (per-listener dedup - the SAY's aux
; is the guest). A guest comes to know of people through the host by hearing it -
; and self-news cascades onward as ordinary gossip. (The old telepathic two-way
; (exchange-news) is gone; the reciprocal half is each guest's OWN catch_up.)
;
; An ACT (tell), but kept here as an occasion (the host life_aim / parent gate is
; the party framing; the friend tie is the guest list). Fired by the per-NPC
; emergent pass MONTHLY, so the host (chance) is /12 (the *0.0667 wrapper) to hold
; the old annual party volume.
;
; Topology: @self (the host) is enumerated (gated by chance); ?guest is a friend of
; the host who is ALSO co-present (the location join). The friend filter already
; excludes infants (no friends), so no age gate is needed.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think birthday_party
  (cooldown 1 m)
  (rng-stream friendships)

  ;; @self is the host. PR-A-8 substrate gate: the canonical host motivation is a
  ;; social life_aim (belonging / respectability - the aims that prize community
  ;; visibility) OR being a parent (parties for one's child). The enthusiasm-scaled
  ;; chance gate lives in (when) below (non-belief filter).
  (role @self (or {@self life_aim belonging_aim}
                  {@self life_aim respectability_aim}
                  {@self identity parent_role}))
  ; A CO-PRESENT friend (the party guest actually in the room): the friend tie is the
  ; guest list; co-presence (objective room occupancy) is who is here to be told.
  (role ?guest (any_human ?guest)
               {@self friend ?guest}
               (co-present @self))

  ;; Non-belief gate kept out of the @self role: enthusiasm-scaled chance, multiplicative
  ;; so outgoing hosts engage more than withdrawn ones, /12'd to the monthly
  ;; cadence, rolled once per host per month.
  (when (chance (* 0.0667 (attr @self enthusiasm))))

  (effects
    ; Tell ?guest ONE piece of the host's own news they have not heard. for-each-present-tense-belief
    ; binds each matched belief as ?belief; the dedup is PER-GUEST - the SAY's aux is
    ; the listener, so {@self SAY <msg> ?guest} is "have I told THIS guest this".
    (for-each-present-tense-belief ?belief {@self spouse|fiancee|lover|child ?}
      (do
        (bind (utterable-msg ?belief) ?msg)
        (if (not (believes {@self SAY ?msg ?guest}))
            (then (tell-to ?guest ?msg) (break)))))
    ))
