; ----------------------------------------------------------------------------
; talk-audit - a man pursues one partner at a time in each kind of talk: he gets acquainted
; with one man, flirts with one, catches up with one, and so on, each driver holding its (lock).
; Two of one kind running at once is the thrash the lock exists to prevent: each pursuit hails its
; own partner, every hail takes its leave of the talk he is in, and he is passed from talk to talk
; without finishing any. Each rule admits that state and counts it.
; ----------------------------------------------------------------------------

(audit audit-two-get-acquainted
  (belief {@self get-acquainted ?}
    (when (>= (count (every {@self get-acquainted ? /pres})) 2))
    (effects (expect @false "talk: getting acquainted with two at once"))))

(audit audit-two-flirts
  (belief {@self flirt ? ?}
    (when (>= (count (every {@self flirt ? ? /pres})) 2))
    (effects (expect @false "talk: flirting with two at once"))))

(audit audit-two-catch-ups
  (belief {@self catch-up ?}
    (when (>= (count (every {@self catch-up ? /pres})) 2))
    (effects (expect @false "talk: catching up with two at once"))))

(audit audit-two-gossip-tellings
  (belief {@self tell-gossip ?}
    (when (>= (count (every {@self tell-gossip ? /pres})) 2))
    (effects (expect @false "talk: telling gossip to two at once"))))

(audit audit-two-find-outs
  (belief {@self find-out ?}
    (when (>= (count (every {@self find-out ? /pres})) 2))
    (effects (expect @false "talk: finding out two things at once"))))

(audit audit-two-inquiries
  (belief {@self inquire ? ?}
    (when (>= (count (every {@self inquire ? ? /pres})) 2))
    (effects (expect @false "talk: inquiring of two at once"))))

(audit audit-talks-with-one-man-an-hour
  (role ?other [k human] {? participant ?other}
    (when (> (talks-with-lately ?other) (k-talks-with-one-man-an-hour)))
    (effects
      (debug-print "talk-limit: @self began (talks-with-lately ?other) talks with ?other within the hour")
      (expect @false "talk: more talks begun with one man within an hour than k-talks-with-one-man-an-hour"))))

; A man tells only what he does not take his listener to know (speech-worthy, funcs/talk.mc), so
; tidings he has told a man are never told that man again.
(audit audit-tidings-retold
  (lint-waive say-search)
  (belief {@self SAY (msg /tidings ? ?..):?msg ?audience}:?SAY
    (when (substantial (any {@self SAY ?msg ?audience /succ /past})))
    (effects
      (debug-print "tidings-retold: @self tells ?audience again ?msg")
      (expect @false "talk: tidings told again to one already told them"))))

(audit audit-two-smalltalks
  (belief {@self smalltalk ? ?}
    (when (>= (count (every {@self smalltalk ? ? /pres})) 2))
    (effects (expect @false "talk: making smalltalk with two at once"))))
