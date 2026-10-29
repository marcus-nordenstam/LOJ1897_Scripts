; ----------------------------------------------------------------------------
; tell ?msg ?audience - THE one-way speech task, and the only one that proposes SAY: say ?msg
; to ?audience where he can hear it. The speaker does the moving, never the man spoken to. Within
; call of his audience he waits while another man is speaking to it or to him (free-to-address),
; then takes his turn (claim-turn: the floor of the conversation he says it in, and the marks on
; whom he says it to) - which holds the listener where he stands -
; and closes on it through go until he would hear it (within-voice: within the radius of the
; sound ?msg makes), and says it; out of call he goes toward it unmarked. A tell to a conversation
; is said where @self stands, to every party in it; a broadcast (an absent ?audience) is said
; where @self stands, so its proposer brings him to the place first. The marks clear when the
; tell ends. A man says one thing at a time (lock speech-act). It succeeds when the SAY does and
; fails when he cannot reach his audience.
;
; Saying something and waiting for an answer is a conversation: converse says each of its
; lines through this task.
; ----------------------------------------------------------------------------

(task {@self tell ?msg ?audience}:?tell
  (unique)
  (once)
  (sub @msgAuthor [k human] @object)
  (tar @msg @excl @pattern)
  (aux @msgAudience ?)
  (lock (speech-act))
  (init (bid-floor ?msg ?audience))
  (cease
    (release-floor)
    (release-addressees ?audience))
  (preemptive-or
    (try
      (role @self {@self SAY ? /succ /caused_by ?tell}
        (effects
          (bb-public-write @self spoke-at (time seconds))
          (set-outcome ?tell /succ))))
    (try
      (role @self {@self go-to ?audience /fail /caused_by ?tell}
        (effects (set-outcome ?tell /fail))))
    (try
      (when (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
                 (free-to-address ?audience)
                 (my-turn ?msg ?audience)))
      (effects
        (bind (claim-turn ?audience) ?claimed)
        (if ?claimed
            (then (maintain-proposal {@self SAY ?msg ?audience})))))
    (try
      (when (and (is-a ?audience [k human]) (within-call ?audience) (free-to-address ?audience)
                 (my-turn ?msg ?audience)))
      (effects
        (bind (claim-turn ?audience) ?claimed)
        (if ?claimed
            (then (maintain-proposal {@self go-to ?audience earshot})))))
    (try
      (when (and (is-a ?audience [k human]) (not (within-call ?audience))))
      (effects (maintain-proposal {@self go-to ?audience earshot})))))
