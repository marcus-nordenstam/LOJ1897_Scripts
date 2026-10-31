; ----------------------------------------------------------------------------
; tell ?msg ?audience - THE one-way speech task, and the only one that proposes SAY: say ?msg
; to ?audience where he can hear it. The speaker does the moving, never the man spoken to. It
; requires that he is within call of a man he tells (in-call-of, funcs/preconditions.mc): out of
; call he goes toward him first. Within call he asks for the turn his line takes (turn-board:
; the conversation he says it in, or the man he calls) and waits until it is handed to him -
; which holds the listener where he stands - then closes on it through go until he would hear
; it (within-voice: within the radius of the sound ?msg makes), and says it. A man being called
; answers before he calls anyone. A tell to a conversation is said where @self stands, to every
; party in it; a broadcast (an absent ?audience) takes no turn and is said where @self stands, so
; its proposer brings him to the place first. The turn gives way when the tell ends, or once the
; SAY it began is said. A man says one thing at a time (lock speech-act). It succeeds when the
; SAY does and fails when he cannot reach his audience.
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
  (preconditions (in-call-of ?audience))
  ; A line to a conversation nobody else is in any more has no one to hear it.
  (failure-cond (and (is-a ?audience [k conversation]) (not (other-party-in ?audience))))
  (cease
    (if (not (speaking))
        (then (release-line-turns ?tell))))
  (preemptive-or
    (try
      (role @self {@self SAY ? /succ /caused_by ?tell}
        (effects (set-outcome ?tell /succ))))
    (try
      (role @self {@self go-to ?audience /fail /caused_by ?tell}
        (effects (set-outcome ?tell /fail))))
    (try
      (when (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
                 (my-turn ?audience)
                 (not (being-called))))
      (effects (maintain-proposal {@self SAY ?msg ?audience})))
    (try
      (when (and (is-a ?audience [k human]) (within-call ?audience)
                 (my-turn ?audience)
                 (not (being-called))))
      (effects (maintain-proposal {@self go-to ?audience earshot})))
    (try
      (bind (turn-board ?audience) ?board)
      (when (and (substantial ?board) (not (holds-turn ?board)) (not (being-called))))
      (effects (turn-request ?board (line-rank ?msg ?audience))))))
