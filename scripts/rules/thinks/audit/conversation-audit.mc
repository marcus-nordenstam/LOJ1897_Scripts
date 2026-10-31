; ----------------------------------------------------------------------------
; conversation-audit - a man pursues one partner at a time in each kind of talk: he gets acquainted
; with one man, flirts with one, catches up with one, and so on, each driver holding its (lock).
; Two of one kind running at once is the thrash the lock exists to prevent: each pursuit hails its
; own partner, every hail takes its leave of the talk he is in, and he is passed from talk to talk
; without finishing any. Each rule admits that state and counts it.
; ----------------------------------------------------------------------------

(audit audit-two-get-acquainted
  (role @self {@self get-acquainted ?}
    (when (>= (count (every {@self get-acquainted ? /pres})) 2))
    (effects (expect @false "conversation: getting acquainted with two at once"))))

(audit audit-two-flirts
  (role @self {@self flirt ? ?}
    (when (>= (count (every {@self flirt ? ? /pres})) 2))
    (effects (expect @false "conversation: flirting with two at once"))))

(audit audit-two-catch-ups
  (role @self {@self catch-up ?}
    (when (>= (count (every {@self catch-up ? /pres})) 2))
    (effects (expect @false "conversation: catching up with two at once"))))

(audit audit-two-gossip-tellings
  (role @self {@self tell-gossip ?}
    (when (>= (count (every {@self tell-gossip ? /pres})) 2))
    (effects (expect @false "conversation: telling gossip to two at once"))))

(audit audit-two-find-outs
  (role @self {@self find-out ?}
    (when (>= (count (every {@self find-out ? /pres})) 2))
    (effects (expect @false "conversation: finding out two things at once"))))

(audit audit-two-inquiries
  (role @self {@self inquire ? ?}
    (when (>= (count (every {@self inquire ? ? /pres})) 2))
    (effects (expect @false "conversation: inquiring of two at once"))))

(audit audit-talks-with-one-man-an-hour
  (role ?other [k human] {? participant ?other}
    (when (> (talks-with-lately ?other) (k-talks-with-one-man-an-hour)))
    (effects
      (debug-print "talk-limit: @self began (talks-with-lately ?other) talks with ?other within the hour")
      (expect @false "conversation: more talks begun with one man within an hour than k-talks-with-one-man-an-hour"))))

(audit audit-two-smalltalks
  (role @self {@self smalltalk ? ?}
    (when (>= (count (every {@self smalltalk ? ? /pres})) 2))
    (effects (expect @false "conversation: making smalltalk with two at once"))))
