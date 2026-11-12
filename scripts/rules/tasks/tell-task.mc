; ----------------------------------------------------------------------------
; tell ?msg ?audience - THE one-way speech task, and the only one that proposes SAY: say ?msg
; to ?audience where he can hear it, in the register he takes toward him (voice-line, funcs/voice.mc). The speaker does the moving, never the man spoken to. It
; requires that he is within call of a man he tells (in-call-of, funcs/preconditions.mc): out of
; call he goes toward him first. Within call he asks for the turn his line takes (turn-board:
; the conversation he says it in, or the man he calls) and waits until it is handed to him -
; which holds the listener where he stands - then closes on it through go until he would hear
; it (within-voice: within the radius of the sound ?msg makes), and says it. A man being called
; answers before he calls anyone, and an answer takes no turn (may-speak): the one it answers asked
; for it. A tell to a conversation is said to every party in it, once he
; has closed on any party out of voice; a broadcast (an absent ?audience) takes no turn and is said where @self stands, so
; its proposer brings him to the place first. The turn gives way when the tell ends, or once the
; SAY it began is said. A man says one thing at a time (lock speech-act). It succeeds when the
; SAY does, the line recorded in the talk he said it in (record-said), and fails when he cannot
; reach his audience.
;
; Saying something and waiting for an answer is a conversation: each of its lines is said
; through this task.
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
      (belief {@self SAY ?said ? /succ /caused_by ?tell}
        (effects
          (record-said ?said (talk-of-line ?audience))
          (set-outcome ?tell /succ))))
    (try
      (lod presented)
      (when (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
                 (or (not (is-a ?audience [k human])) (visible ?audience))
                 (may-speak ?msg ?audience)))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    ; Unpresented there are no turns and no hails: one line stands on a speaker and his listener at
    ; a time, so nobody speaks to a man being spoken to and nobody speaks to two at once.
    (try
      (lod unpresented)
      (sync talk @self ?audience)
      (when (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
                 (or (not (is-a ?audience [k human])) (visible ?audience))))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    (try
      (lod presented)
      (when (and (is-a ?audience [k human]) (within-call ?audience)
                 (may-speak ?msg ?audience)))
      (effects (maintain-proposal {@self go-to ?audience earshot})))
    (try
      (lod unpresented)
      (when (and (is-a ?audience [k human]) (within-call ?audience)
                 (not (and (within-voice ?audience ?msg) (visible ?audience)))))
      (effects (maintain-proposal {@self go-to ?audience earshot})))
    (try
      (bind (party-out-of-voice ?audience ?msg) ?far)
      (when (and (substantial ?far) (may-speak ?msg ?audience)))
      (effects (maintain-proposal {@self go-to ?far earshot})))
    (try
      (bind (turn-board ?audience) ?board)
      (when (and (substantial ?board) (not (holds-turn ?board)) (not (being-called))
                 (not (answering-line ?msg ?audience))))
      (effects (turn-request ?board (line-rank ?msg ?audience))))))
