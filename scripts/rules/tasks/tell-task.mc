; ----------------------------------------------------------------------------
; tell ?msg ?audience - THE one-way speech task, and the only one that proposes SAY: say ?msg
; to ?audience where he can hear it. A directed tell first closes on its audience through
; go until he would hear it (within-voice: within the radius of the sound ?msg makes); a tell
; to a conversation is said where @self stands, to every party in it; a broadcast (an absent
; ?audience) is said where @self stands, so its proposer brings him to the place first. Within
; voice, he waits while another man is speaking to his audience (free-to-address), then marks
; it as his to speak to (claim-addressees) and says it; the mark clears when the tell ends. It
; succeeds when the SAY does and fails when he cannot reach his audience.
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
  (cease (release-addressees ?audience))
  (preemptive-or
    (try
      (when {@self SAY ? /succ /caused_by ?tell})
      (effects (set-outcome ?tell /succ)))
    (try
      (when {@self go-to ?audience /fail /caused_by ?tell})
      (effects (set-outcome ?tell /fail)))
    (try
      (when (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
                 (free-to-address ?audience)))
      (effects
        (bind (claim-addressees ?audience) ?claimed)
        (if ?claimed
            (then (maintain-proposal {@self SAY ?msg ?audience})))))
    (try
      (when (and (is-a ?audience [k human]) (not (within-voice ?audience ?msg))))
      (effects (maintain-proposal {@self go-to ?audience})))))
