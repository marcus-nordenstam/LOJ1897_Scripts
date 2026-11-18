; ----------------------------------------------------------------------------
; Saying a line, pursued. An intent to say ?msg to ?audience ({@self intent {@self SAY ?msg
; ?audience}}) is held by whatever wants the line said - a task maintains it while it wants it, or
; begins it to have it said whatever comes after - and this is the one rule that proposes SAY. The
; speaker does the moving, never the man spoken to. What must hold before the line is said is
; PREPARATION, and each rung gets one of them:
;   he is with ?audience, a man: out of his voice he goes to him;
;   every party of a talk he tells would hear him: he closes on one out of voice;
;   presented, he holds the turn the line takes, a talk's (turn-board, funcs/talk.mc): he asks
;     for it and waits until it is handed to him, a reply first of those waiting (line-rank). A
;     line to a man in no talk takes none.
; With all of it in hand he says the line, in the register he takes toward ?audience (voice-line,
; funcs/voice.mc). A broadcast (an absent ?audience) takes no turn and is said where he stands.
; Unpresented there are no turns: one line stands on a speaker and his listener at a time (sync).
; The SAY said ends the intent; what follows from the line being said is the said reflex's
; (reflexes/said.mc). A line to a talk nobody else is in has no one to hear it, and a man he cannot
; get to is not told: the intent is given up.
; ----------------------------------------------------------------------------

; (in-voice-of ?audience ?msg) - ?audience would hear and see @self say ?msg where he stands.
(define-func in-voice-of (?audience ?msg)
  (and (or (unsubstantial ?audience) (within-voice ?audience ?msg))
       (or (not (is-a ?audience [k human])) (visible ?audience))))

(driver {@self intent {@self SAY ?msg ?audience}}:?intent
  (and
    (try
      (lod presented)
      (when (and (in-voice-of ?audience ?msg) (may-speak ?audience)))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    (try
      (lod unpresented)
      (sync talk @self ?audience)
      (when (in-voice-of ?audience ?msg))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    (try
      (lod presented)
      (when (and (is-a ?audience [k human])
                 (not (in-voice-of ?audience ?msg))
                 (or (not (within-call ?audience)) (may-speak ?audience))))
      (effects (maintain-proposal {@self go-to ?audience earshot} /preparatory)))
    (try
      (lod unpresented)
      (when (and (is-a ?audience [k human]) (not (in-voice-of ?audience ?msg))))
      (effects (maintain-proposal {@self go-to ?audience earshot} /preparatory)))
    (try
      (bind (party-out-of-voice ?audience ?msg) ?far)
      (when (and (substantial ?far) (may-speak ?audience)))
      (effects (maintain-proposal {@self go-to ?far earshot} /preparatory)))
    (try
      (lod presented)
      (bind (turn-board ?audience) ?board)
      (when (and (substantial ?board) (not (holds-turn ?board))))
      (effects (turn-request ?board (line-rank ?msg ?audience))))
    (try
      (when (and (is-a ?audience [k talk]) (not (other-party-in ?audience))))
      (effects (forsake-intent ?intent)))
    (try
      (belief {@self go-to ? earshot /fail /caused_by ?intent}
        (effects (forsake-intent ?intent))))))
