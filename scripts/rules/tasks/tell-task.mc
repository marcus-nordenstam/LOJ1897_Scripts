; ----------------------------------------------------------------------------
; tell ?msg ?audience - THE one-way speech task, and the only one that proposes SAY: say ?msg
; to ?audience where he can hear it. A directed tell first closes on its audience through
; go until he would hear it (within-voice: within the radius of the sound ?msg makes); a
; broadcast (an absent ?audience) is said where @self stands, so its proposer brings him
; to the place first. It succeeds when the SAY does and fails when he cannot reach his
; audience.
;
; Saying something and waiting for an answer is a conversation: converse says each of its
; lines through this task.
; ----------------------------------------------------------------------------

(task {@self tell ?msg ?audience}:?tell
  (sub @msgAuthor [k human] @object)
  (tar @msg @excl @pattern)
  (aux @msgAudience ?)
  (preemptive-or
    (try
      (when {@self SAY ? /succ /caused_by ?tell})
      (effects (set-outcome ?tell /succ)))
    (try
      (when {@self go ?audience /fail /caused_by ?tell})
      (effects (set-outcome ?tell /fail)))
    (try
      (when (or (unsubstantial ?audience) (within-voice ?audience ?msg)))
      (effects (maintain-proposal {@self SAY ?msg ?audience})))
    (try
      (effects (maintain-proposal {@self go ?audience})))))
