; ----------------------------------------------------------------------------
; birthday-party-driver (think). The recurring news-exchange that drives long-tail
; gossip: once a year a share of NPCs hold a party, and each pair of (host,
; friend-of-host) exchanges the news of the past year. Ceremonies (betrothal /
; wedding / christening) carry milestones to a bounded guest list; this carries
; everything else, lossily and slowly.
;
; The host TELLS the conversation he is in, with a friend in it, a piece of his own news someone
; in it has not been told (worthy-for, funcs/conversation.mc). A guest comes to know of people
; through the host by hearing
; it - and self-news cascades onward as ordinary gossip. The guests' own news travels the same
; way, told in the conversations they hold with their friends (catch-up).
;
; An ACT (tell), but kept here as an occasion (the host life-aim / parent gate is
; the party framing; the friend tie is the guest list). Fired by the per-NPC
; emergent pass MONTHLY, so the host (chance) is /12 (the *0.0667 wrapper) to hold
; the old annual party volume.
; ----------------------------------------------------------------------------


(driver birthday-party-driver
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
        (role @self {@self news ?told}:?news
                    (worthy-for ?told ?talk)
                    (select (policy first-match))

          ;; Non-belief gate, not a @self role filter: enthusiasm-scaled chance, multiplicative
          ;; so outgoing hosts engage more than withdrawn ones, /12'd to the monthly
          ;; cadence, rolled once per host per month.
          (when (chance (* 0.0667 ?enthusiasm)))

          (declare-utility want)

          (effects
            (msg /utterable [] ?told): ?msg
            (maintain-proposal {@self tell ?msg ?talk} /quit-trying-on-fail)))))))
