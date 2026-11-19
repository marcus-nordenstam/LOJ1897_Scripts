; ----------------------------------------------------------------------------
; Saying a line, pursued. An intent to say ?msg to ?audience ({@self intent {@self SAY ?msg
; ?audience}}) is held by whatever wants the line said - a task maintains it while it wants it, or
; begins it to have it said whatever comes after - and this is the one rule that proposes SAY. The
; speaker does the moving, never the man spoken to. What must hold before the line is said is
; PREPARATION, and each rung gets one of them:
;   he is with ?audience, a man: out of earshot he goes to him;
;   every participant of a talk he tells would hear him: he closes on one out of earshot;
;   the line has a talk to be said in (turn-board, funcs/talk.mc): a man he is not talking with is
;     hailed first, the hail standing until the two are talking; turned down, the line is given up;
;   presented, he holds the turn that talk gives: he asks for it and waits until it is handed to
;     him, a reply first of those waiting (line-rank).
; With all of it in hand he says the line, in the register he takes toward ?audience (voice-line,
; funcs/voice.mc). EVERY LINE TO A MAN OR A TALK TAKES A TURN, whatever it is; only a broadcast (an
; absent ?audience) takes none and is said where he stands.
; Unpresented there are no turns, but the line still needs its talk: one line stands on a speaker
; and his listener at a time (sync).
; The SAY said ends the intent; what follows from the line being said is the SAY's own, as it
; ends (line-said, funcs/speech.mc). A line to a talk nobody else is in has no one to hear it, and a man he cannot
; get to is not told: the intent is given up.
; ----------------------------------------------------------------------------

; (in-sight-and-earshot ?audience ?msg) - ?audience would hear and see @self say ?msg where he stands.
(define-func in-sight-and-earshot (?audience ?msg)
  (and (or (unsubstantial ?audience) (msg-in-earshot ?audience ?msg))
       (or (not (is-a ?audience [k human])) (visible ?audience))))

; (line-can-reach ?audience) - a line to ?audience can come to be said: it has a talk to be said in,
; or he may be hailed into one. He is not walked up to otherwise.
(define-func line-can-reach (?audience)
  (or (addressable ?audience) (hailable ?audience)))

(driver {@self intent {@self SAY ?msg ?audience}}:?intent
  (and
    (try
      (lod presented)
      (when (and (in-sight-and-earshot ?audience ?msg) (my-turn ?audience)))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    (try
      (lod unpresented)
      (sync talk @self ?audience)
      (when (and (in-sight-and-earshot ?audience ?msg) (addressable ?audience)))
      (bind (voice-line ?msg ?audience) ?line)
      (effects (maintain-proposal {@self SAY ?line ?audience})))
    (try
      (lod presented)
      (when (and (is-a ?audience [k human])
                 (not (in-sight-and-earshot ?audience ?msg))
                 (line-can-reach ?audience)
                 (or (not (in-shouting-distance ?audience)) (my-turn ?audience) (not (addressable ?audience)))))
      (effects (maintain-proposal {@self go-to ?audience earshot} /preparatory)))
    (try
      (lod unpresented)
      (when (and (is-a ?audience [k human])
                 (not (in-sight-and-earshot ?audience ?msg))
                 (line-can-reach ?audience)))
      (effects (maintain-proposal {@self go-to ?audience earshot} /preparatory)))
    (try
      (bind (participant-out-of-earshot ?audience ?msg) ?far)
      (when (and (substantial ?far) (my-turn ?audience)))
      (effects (maintain-proposal {@self go-to ?far earshot} /preparatory)))
    (try
      (lod presented)
      (bind (turn-board ?audience) ?board)
      (when (and (substantial ?board) (not (holds-turn ?board))))
      (effects (turn-request ?board (line-rank ?msg ?audience))))
    ; A man he is not talking with is hailed before he is spoken to, from where the line would be
    ; said, and the hail stands until the two are talking. A man whose own hail of him stands
    ; unanswered he answers, and does not hail.
    (try
      (when (and (is-a ?audience [k human])
                 (in-sight-and-earshot ?audience ?msg)
                 (not (conversing-with ?audience))
                 (not (hailed-by ?audience))
                 (hailable ?audience)))
      (effects (maintain-proposal {@self hail ?audience} /preparatory)))
    (try
      (belief {@self hail ?audience /fail /caused_by ?intent}
        (when (not (conversing-with ?audience)))
        (effects (forsake-intent ?intent))))
    (try
      (when (and (is-a ?audience [k talk]) (not (other-participant-in ?audience))))
      (effects (forsake-intent ?intent)))
    (try
      (belief {@self go-to ? earshot /fail /caused_by ?intent}
        (effects (forsake-intent ?intent))))))
