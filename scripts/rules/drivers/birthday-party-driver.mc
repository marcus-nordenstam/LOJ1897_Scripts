; ----------------------------------------------------------------------------
; birthday-party (think). The recurring news-exchange that drives long-tail
; gossip: once a year a share of NPCs hold a party, and each pair of (host,
; friend-of-host) exchanges the news of the past year. Ceremonies (betrothal /
; wedding / christening) carry milestones to a bounded guest list; this carries
; everything else, lossily and slowly.
;
; The host TELLS the conversation he is in, with a friend in it, the freshest piece of his own
; news that someone in it has not heard: (pick-untold-belief /news ?talk) picks it over the
; (facets news-worthy) labels in their (tell-rank) order, skipping what the listeners are party
; to or were told in his hearing. A guest comes to know of people through the host by hearing
; it - and self-news cascades onward as ordinary gossip. The guests' own news travels the same
; way, told in the conversations they hold with their friends (friend-talk).
;
; An ACT (tell), but kept here as an occasion (the host life-aim / parent gate is
; the party framing; the friend tie is the guest list). Fired by the per-NPC
; emergent pass MONTHLY, so the host (chance) is /12 (the *0.0667 wrapper) to hold
; the old annual party volume.
; ----------------------------------------------------------------------------


(driver birthday-party
  (cooldown 1 m try-once)
  (rng-stream friendships)

  ;; @self is the host. PR-A-8 substrate gate: the canonical host motivation is a
  ;; social life-aim (belonging / respectability - the aims that prize community
  ;; visibility) OR being a parent (parties for one's child). The enthusiasm-scaled
  ;; chance gate lives in (when) below (non-belief filter).
  (role @self {@self enthusiasm ?enthusiasm}
              (or {@self life-aim belonging-aim}
                  {@self life-aim respectability-aim}
                  {@self identity parent-role})
    ; The conversation @self is in, with a friend of his in it: the friend tie is the guest list.
    (role ?talk {?talk participant @self} {?talk venue ?}
      (role ?guest {?talk participant ?guest} {@self friend ?guest}
        (bind (pick-untold-belief /news ?talk) ?news)

        ;; Non-belief gate, not a @self role filter: enthusiasm-scaled chance, multiplicative
        ;; so outgoing hosts engage more than withdrawn ones, /12'd to the monthly
        ;; cadence, rolled once per host per month.
        (when (and (substantial ?news) (chance (* 0.0667 ?enthusiasm))))

        (declare-utility want)

        (effects
          (msg /utterable [] ?news): ?msg
          (maintain-proposal {@self tell ?msg ?talk} /quit-trying-on-fail))))))
