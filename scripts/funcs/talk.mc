; ----------------------------------------------------------------------------
; talk.mc - who hears whom, how a man answers being hailed, and how a talk
; he opened goes.
;
; Speech has one rule that proposes SAY: the driver of an intent to say (drivers/say-driver.mc)
; says one thing where its audience can hear it. A man is in a talk while he holds
; {<talk> participant @self}: a hail taken up or a take-up begins it, and leaving ends it
; (drivers/stay-in-talk-driver.mc).
; Everything he says in it, and every way he leaves it, keys off that part;
; maintain-social-presence only keeps his body with the others.
;
; A TALK is ONE object, shared (share-object): the opener invents it, and every party
; holds his own copy of it, linked to the one the world keeps. Its public board is what keeps the
; group in step: its participant set is who takes part (talk-participants) and its has-more set who still
; has something to say. Joining adds him to the set and leaving takes him off it; a change to
; either set wakes every party reading it, busy or not, and each mirrors it in his own mind
; (talk-roster-join / -leave). When the last party leaves, the board is empty and the
; world lets the talk go. What a man knows of a talk
; is his own beliefs, kept to the board: {<talk> participant <party>} for each party, one
; interval per spell (talk-roster-join / -leave), {<talk> venue <space>} while he is in
; it, {<talk> occasion <occasion>} when it is part of one.
;
; A HAIL is a man calling @self into a talk, the same at both levels of detail and kept on the
; boards. It is called IN a talk from its first instant: the one @self is in, else the hailer's
; own, else a new one the hailer makes, whose participant set he puts both of them on
; (call-into-talk) - so whoever speaks to either of them finds one talk and waits for its turn.
; Being on a talk's board is being called into it; holding his part in it, {<talk> participant
; @self}, is having agreed: @self holds his once he takes the hail up, the hailer his once it is
; taken up. The hail is CALLED by its opening, a (formulaic opening-phrase ..) said to @self and
; logged in that talk like any line: while it stands there with no reply of his, he is being called
; (caller-in). His reply to it is his answer - the response that takes it up, or the refusal or
; rebuff that turns it down - and what he answered is also kept in the hailer's bbk-hail-answer
; record of him (boards/talk.mc), which outlives the talk. It is always answered, and how is his
; choice: he takes up the talk, declines it for what he is busy with, or rebuffs a man he despises
; (drivers/answer-hail-driver.mc). A hail that ends without being taken up takes off the board whom
; it put there (uncall).
;
; The funcs at the foot are the player's side, asked by the host: whom he can hail, his
; opening and parting lines, and whether a man has taken him up.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")
(include "../macros/formulaic-macros.mc")
(include "../macros/leisure-macros.mc")


; (voice-sound ?msg) - the sound saying ?msg makes: a [k shout] when it rides a raised voice
; ([/voice-mod shout]), else [k speech]. Only a behaviour that shouts writes the rider; any other
; speaker closes on his listener and speaks.
(define-func voice-sound (?msg)
  (flip (eq (msg-rider ?msg voice-mod) shout) [k shout] [k speech]))

; (within-call ?listener) - ?listener would hear @self call out, as @self knows where he
; stands - seen, or heard: a voice places the man it came from.
(define-func within-call (?listener)
  (in-earshot ?listener [k shout]))

; (within-voice ?listener ?msg) - ?listener would hear @self say ?msg: a person within earshot,
; a talk when every party @self knows to be in it is. tell closes on its audience until
; this holds.
(define-func within-voice (?listener ?msg)
  (if (and (is-object ?listener) (is-a ?listener [k talk]))
      (then (unsubstantial (party-out-of-voice ?listener ?msg)))
      (else (in-earshot ?listener (voice-sound ?msg)))))

; (party-out-of-voice ?talk ?msg) - a party @self knows to be in ?talk who would not hear him say
; ?msg where he stands, or @nothing.
(define-func party-out-of-voice (?talk ?msg)
  (bind @nothing ?far)
  (for-each ?party (every {?talk participant ?})
    (bind ?party.target ?who)
    (if (and (neq ?who @self) (not (in-earshot ?who (voice-sound ?msg))))
        (then (bind ?who ?far) (break))))
  ?far)

; (answers-to ?speaker) - @self is bound to heed ?speaker's hail: his master, his mother or
; his father.
(define-func answers-to (?speaker)
  (any {@self master|mother|father ?speaker}))

; (law-officer ?x) - @self believes ?x holds a job of a law officer's kind.
(define-func law-officer (?x)
  (substantial (any {?x job [k law-officer]})))

; (evading-law) - @self has the law to fear: he remembers a crime of his own.
(define-func evading-law ()
  (substantial (any {@self kill|shoot|strangle|hurt|steal|coerce|bribe ? /succ /past})))

(define-func hail-want-utility (?value)
  (utility want ?value))

; (obligation-hail ?speaker) - a hail @self must take up however he feels: a law officer's when he
; has nothing to hide, or one from a man he answers to.
(define-func obligation-hail (?speaker)
  (or (and (law-officer ?speaker) (not (evading-law))) (answers-to ?speaker)))

; (too-crowded-for ?speaker) - @self has had his fill of company and ?speaker's hail does not oblige
; him: he turns it down.
(define-func too-crowded-for (?speaker)
  (and (substantial (any {@self company [k crowded]})) (not (obligation-hail ?speaker))))

; (hail-utility ?speaker) - what taking up ?speaker's hail is worth to @self, as a packed
; utility: an obligation when it is a law officer's and he has nothing to hide, or when he
; answers to ?speaker, else a want that rises with how close they are.
(define-func hail-utility (?speaker)
  (cond (case (and (law-officer ?speaker) (not (evading-law)))
              (utility obligation (k-hail-authority-value)))
        (case (answers-to ?speaker) (utility obligation (k-hail-bond-value)))
        (case {@self spouse|lover|friend|close-to|mother|father|child|sibling ?speaker}
              (hail-want-utility (k-hail-bond-value)))
        (case {@self acquaintance ?speaker} (hail-want-utility (k-hail-acquaintance-value)))
        (else (hail-want-utility (k-hail-stranger-value)))))

; (hail-response ?opening) - the response a hail's opening calls for: a man who introduced
; himself by his office ((formulaic [] opening-phrase authority <job kind>)) is answered by it, any
; other opening by its own key. A (formulaic ..) quotes its args, so the office and the key are
; read off the opening first.
(define-func hail-response (?opening)
  (if (matches ?opening (formulaic ? opening-phrase authority ?..))
      (then (bind (nth (k-formulaic-office-field) ?opening) ?office)
            (formulaic [] response authority ?office))
      (else (bind (nth (k-formulaic-key-field) ?opening) ?key)
            (formulaic [] response ?key))))

; (rebuffs ?speaker) - @self rebuffs ?speaker's hail: he despises him and does not answer to him.
(define-func rebuffs (?speaker)
  (and (any {@self despise ?speaker}) (not (answers-to ?speaker))))

; (taking-up ?caller) - @self has begun taking up ?caller's talk.
(define-func taking-up (?caller)
  (substantial (any {@self take-up ?caller})))

; (happened-since ?event ?since) - ?event came no earlier than ?since: than its end once it is
; over, than its start while it runs.
(define-func happened-since (?event ?since)
  (<= (elapsed /seconds ?event) (elapsed /seconds ?since)))

; (any-happened-since ?events ?since) - one of the events in the list ?events came since ?since.
(define-func any-happened-since (?events ?since)
  (bind @false ?found)
  (for-each ?one ?events
    (if (happened-since ?one ?since)
        (then
          (bind @true ?found)
          (break))))
  ?found)

; (talk-of ?party) - the talk whose participant set holds ?party, or @nothing. A
; man takes part in one talk at a time.
(define-func talk-of (?party)
  (bind @nothing ?talk)
  (for-each ?one (bb-public-every ? participant ?party)
    (bind ?one ?talk)
    (break))
  ?talk)

; (line-hearers ?audience) - whom a line said to ?audience is for: the people on the board of the
; talk it is said in - ?audience when its board holds participants, else the talk ?audience is in -
; or @nothing for
; a line said in no talk, which everyone in earshot hears. Nobody listens in on a talk he is not
; in: eavesdropping is a thing a man sets out to do, and no rule has him do it yet.
(define-func line-hearers (?audience)
  (cond (case (unsubstantial ?audience) @nothing)
        (case (not (empty (talk-participants ?audience))) (talk-participants ?audience))
        (case (substantial (talk-of ?audience)) (talk-participants (talk-of ?audience)))
        (else @nothing)))

; (in-talk ?party ?talk) - ?talk's participant set holds ?party.
(define-func in-talk (?party ?talk)
  (and (substantial ?talk) (substantial (bb-public-any ?talk participant ?party))))

; (shared-talk ?party) - the talk @self and ?party both take part in, or @nothing: the
; discourse a line ?party says to him belongs to. A line overheard from a talk he is not in has none.
(define-func shared-talk (?party)
  (flip (in-one-talk @self ?party) (talk-of @self) @nothing))

; A LINE SAID TO A MAN IN A TALK IS SAID IN THAT TALK, and the talk's log (bbk-line, boards/talk.mc)
; records it. The line it replies to rides on its message (the reply-to rider): that is how a reply
; is told from its line, in either mind. A hail puts the man it calls in a talk before its opening is said, so an opening is logged
; like any line. A reply goes into the talk of the line it replies to. A line to a man in no talk -
; nobody has called him - is in none and is logged nowhere.

; (logged-in ?talk ?line) - ?talk when its log holds the line ?line, else @nothing.
(define-func logged-in (?talk ?line)
  (if (and (substantial ?talk) (substantial (bb-public-read-rec ?talk bbk-line ?line)))
      (then ?talk)
      (else @nothing)))

; (said-in ?line) - the talk whose log holds the line ?line, or @nothing: the talk it was said to, or
; a talk its speaker or its audience is in.
(define-func said-in (?line)
  (bind ?line.subject ?speaker)
  (bind ?line.auxiliary ?audience)
  (bind @nothing ?found)
  (if (and (is-object ?audience) (is-a ?audience [k talk]))
      (then (bind (logged-in ?audience ?line) ?found)))
  (if (unsubstantial ?found)
      (then (bind (logged-in (talk-of ?speaker) ?line) ?found)))
  (if (and (unsubstantial ?found) (is-object ?audience) (is-a ?audience [k human]))
      (then (bind (logged-in (talk-of ?audience) ?line) ?found)))
  ?found)

; (line-talk ?audience ?replied) - the talk a line @self says to ?audience goes into: the one the line
; ?replied it replies to was said in; else ?audience itself when it is a talk; else the one the two
; would talk in (talk-between); else @nothing - a broadcast, or a line to a man in no talk.
(define-func line-talk (?audience ?replied)
  (bind @nothing ?talk)
  (if (is-belief ?replied)
      (then (bind (said-in ?replied) ?talk)))
  (if (and (unsubstantial ?talk) (substantial ?audience))
      (then
        (if (is-a ?audience [k talk])
            (then (bind ?audience ?talk))
            (else (bind (talk-between ?audience) ?talk)))))
  ?talk)

; (record-line ?SAY ?audience) - the line ?SAY @self said to ?audience, logged in the talk it went
; into (line-talk); that talk, or @nothing when it went into none. An opening said to a man is a hail whoever says it: the talk's record of that man
; says he is called, by @self (bbk-hail, boards/talk.mc).
(define-func record-line (?SAY ?audience)
  (bind (line-talk ?audience (replied-line ?SAY)) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-write-rec ?talk bbk-line ?SAY [])
        (if (and (is-object ?audience) (is-a ?audience [k human])
                 (matches ?SAY.target (formulaic ? opening-phrase ?..)))
            (then (bb-public-write-rec ?talk bbk-hail ?audience (/caller @self /state called /line ?SAY))))))
  ?talk)

; (hail-talk ?caller ?called) - the talk whose board holds ?caller's hail of ?called (bbk-hail), or
; @nothing.
(define-func hail-talk (?caller ?called)
  (bind @nothing ?found)
  (for-each ?talk (bb-public-every ? bbk-hail ?called)
    (if (eq (bb-public-read-rec ?talk bbk-hail ?called caller) ?caller)
        (then (bind ?talk ?found) (break))))
  ?found)

; (hail-state ?caller ?called) - the state of ?caller's hail of ?called: called, taken or turned-down,
; or @nothing when none stands.
(define-func hail-state (?caller ?called)
  (bind (hail-talk ?caller ?called) ?talk)
  (cond (case (unsubstantial ?talk) @nothing)
        (else (bb-public-read-rec ?talk bbk-hail ?called state))))

; (set-hail-state ?caller ?state) - @self answers ?caller's hail of him: its record says ?state, taken
; or turned-down. A hail that no longer stands has no record to answer.
(define-func set-hail-state (?caller ?state)
  (bind (hail-talk ?caller @self) ?talk)
  (if (substantial ?talk)
      (then (bb-public-write-rec ?talk bbk-hail @self (/state ?state)))))

; (hail-line ?caller ?called) - the opening ?caller called ?called with, as @self holds it, or
; @nothing when no hail of his stands or @self did not hear it.
(define-func hail-line (?caller ?called)
  (bind (hail-talk ?caller ?called) ?talk)
  (bind @nothing ?line)
  (if (substantial ?talk)
      (then (bind (bb-public-read-rec ?talk bbk-hail ?called line) ?line)))
  (flip (is-belief ?line) ?line @nothing))

; (called-in ?talk) - @self is called in ?talk and has not answered.
(define-func called-in (?talk)
  (eq (bb-public-read-rec ?talk bbk-hail @self state) called))

; (calling ?partner) - a call of @self's stands on ?partner, answered or not.
(define-func calling (?partner)
  (substantial (hail-state @self ?partner)))

; (called-by ?partner) - a call of ?partner's stands on @self, unanswered.
(define-func called-by (?partner)
  (eq (hail-state ?partner @self) called))

; (saying-opening ?partner) - an opening of @self's to ?partner is on his mouth.
(define-func saying-opening (?partner)
  (substantial (any {@self SAY (formulaic ? opening-phrase ?..) ?partner})))

; (clear-hail ?called) - @self's hail of ?called is over: its record goes.
(define-func clear-hail (?called)
  (bind (hail-talk @self ?called) ?talk)
  (if (substantial ?talk)
      (then (bb-public-clear-rec ?talk bbk-hail ?called))))

; (let-go-talk ?talk) - when nobody is on ?talk's board any more its log goes, and with it the board
; that keeps the talk.
(define-func let-go-talk (?talk)
  (if (and (substantial ?talk) (empty (talk-participants ?talk)))
      (then (bb-public-clear ?talk bbk-line))))

; (call-into-talk ?partner) - @self's hail of ?partner is called in a talk from now: ?partner's when he
; is in one, where @self waits for its turn like anyone; else @self's own, or a new one he makes and
; goes on the board of, which he puts ?partner on the board of and notes (bbk-called). Whoever speaks
; to ?partner from now finds him in that talk.
(define-func call-into-talk (?partner)
  (if (unsubstantial (talk-of ?partner))
      (then
        (bind (talk-of @self) ?talk)
        (if (unsubstantial ?talk)
            (then
              (bind (open-talk) ?talk)
              (bb-public-add-member ?talk participant @self)))
        (bb-public-add-member ?talk participant ?partner)
        (bb-write-rec @self bbk-called ?partner (/talk ?talk)))))

; (uncall ?partner) - @self's hail of ?partner is over: taken up - by ?partner, or @self having taken
; up a hail of ?partner's meanwhile - the note of it goes and the two stay in their talk; else
; ?partner comes off the board of the talk the hail put him on, and so does @self when he holds no
; part in it, and a talk nobody is left on is let go.
(define-func uncall (?partner)
  (bind (bb-read-rec @self bbk-called ?partner talk) ?talk)
  (if (substantial ?talk)
      (then
        (bb-clear-rec @self bbk-called ?partner)
        (if (not (taken-up-with ?partner))
            (then
              (bb-public-remove-member ?talk participant ?partner)
              (if (unsubstantial (any {?talk participant @self}))
                  (then (bb-public-remove-member ?talk participant @self)))
              (let-go-talk ?talk))))))

; (in-one-talk ?party ?partner) - both are on one talk's board: a talk they share or one of them
; called the other into, not yet a talk between them (conversing-with).
(define-func in-one-talk (?party ?partner)
  (in-talk ?partner (talk-of ?party)))

; A LINE IN A TALK TAKES ITS TURN: one man at a time speaks in a talk, the rest wait for its turn,
; and the man who is done hands it on (turn-request, holds-turn, turn-release - the engine's). A
; turn is a talk's and nothing else's, so a line needs one board at most: a line to a talk, or to a
; man in one, takes that talk's turn; a line to a man in no talk takes none, and neither does a
; broadcast. A reply takes its turn like any line and goes first of those waiting (line-rank), so
; it is said once the line it replies to is over; of the others the man longest since he last
; spoke goes first. A man spoken to in his talk stays where he is (heed-speaker).

; (turn-board ?audience) - the talk whose turn a line to ?audience takes, or @nothing.
(define-func turn-board (?audience)
  (cond (case (unsubstantial ?audience) @nothing)
        (case (is-a ?audience [k talk]) ?audience)
        (case (in-one-talk @self ?audience) (talk-of @self))
        (case (substantial (talk-of ?audience)) (talk-of ?audience))
        (else @nothing)))

; A REPLY SAYS WHAT IT REPLIES TO, ON ITSELF: the rule that wants a reply said puts the line it
; replies to on the message as its reply-to rider (as-reply-to), and the line carries it wherever it
; goes - in the SAY, in the talk's log, in each hearer's memory of it. The rider is the line itself,
; an act the world holds: every hearer of it reads it as his own copy of that line.

; (as-reply-to ?msg ?line) - the message ?msg as a reply to the line ?line.
(define-func as-reply-to (?msg ?line)
  (set-msg-rider ?msg reply-to ?line))

; (replied-to ?msg) - the line the message ?msg replies to, as it carries it, or @nothing.
(define-func replied-to (?msg)
  (bind (msg-rider ?msg reply-to) ?replied)
  (flip (is-belief ?replied) ?replied @nothing))

; (replied-line ?line) - the line the line ?line replies to, as its message carries it, or @nothing.
(define-func replied-line (?line)
  (replied-to ?line.target))

; (means-to-tell ?audience) - @self holds an intent to say something to ?audience.
(define-func means-to-tell (?audience)
  (substantial (any {@self intent {@self SAY ? ?audience}})))

; (log-said ?SAY ?audience) - the line ?SAY, said by @self to ?audience to its end, is logged in the
; talk it goes into; that talk, or @nothing for a broadcast. A line logged already is not logged again.
(define-func log-said (?SAY ?audience)
  (bind (said-in ?SAY) ?logged)
  (cond (case (substantial ?logged) ?logged)
        (else (record-line ?SAY ?audience))))

; (answering-line ?msg ?audience) - the line @self is telling ?audience answers one ?audience said
; to him: the line its message replies to is his.
(define-func answering-line (?msg ?audience)
  (bind (replied-to ?msg) ?line)
  (and (is-belief ?line) (eq ?line.subject ?audience)))

; (line-rank ?msg ?audience) - how soon a line waits its turn: an answer goes first.
(define-func line-rank (?msg ?audience)
  (flip (answering-line ?msg ?audience) 1 0))

; (my-turn ?audience) - @self may speak to ?audience now: the line takes no turn, or he holds it.
(define-func my-turn (?audience)
  (bind (turn-board ?audience) ?board)
  (or (unsubstantial ?board) (holds-turn ?board)))

; (may-speak ?audience) - @self may say a line to ?audience now: it takes no turn, or he holds it.
(define-func may-speak (?audience)
  (my-turn ?audience))

; (spoken-to) - another man holds the turn of the talk @self is in.
(define-func spoken-to ()
  (bind (talk-of @self) ?talk)
  (and (substantial ?talk) (turn-held-by-another ?talk)))

; (speaking) - a line of @self's is being said: his SAY runs, and it holds his turn until it ends
; however it ends, whatever became of the intent behind it.
(define-func speaking ()
  (substantial (any {@self SAY ?})))

; (conversing-with ?partner) - @self and ?partner talk together: both are in one talk, and
; since @self joined it a hail between them has been answered - his hail taken up, or ?partner's
; taken up by him. Being in one talk with a man is not yet talking to him.
(define-func conversing-with (?partner)
  (bind (talk-of @self) ?talk)
  (bind (any {?talk participant @self}) ?part)
  (and (is-belief ?part)
       (in-talk ?partner ?talk)
       (or (any-happened-since (every {@self hail ?partner /succ}) ?part)
           (any-happened-since (every {@self take-up ?partner /succ}) ?part))))

; (pursuit-utility ?partner ?base) - what pursuing ?partner in talk is worth to @self, in the want
; band, from ?base: his warmth toward him, less for every other man already holding him
; (partner-claims), and held down for a while after they part, so the keenest partner wins and
; partners change without thrashing.
(define-func pursuit-utility (?partner ?base)
  (bind (/ (* ?base 0.5 (+ 1.0 (stance ?partner warmth)) (social-appetite))
           (+ 1.0 (* (k-partner-busy-weight) (partner-claims ?partner)))) ?appeal)
  (bind (any {? participant @self /past /most_recent}) ?left)
  (bind @nothing ?parted)
  (if (is-belief ?left)
      (then (bind ?left.subject ?left-talk)
            (if (substantial (any {?left-talk participant ?partner /ever}))
                (then (bind ?left ?parted)))))
  (cond (case (is-belief ?parted)
              (* ?appeal (clamp (/ (+ /float (elapsed /minutes ?parted) 0) (k-partner-refresh-minutes)) (k-partner-fresh-floor) 1.0)))
        (else ?appeal)))

; (partner-claims ?partner) - how many other men already hold ?partner: the other parties of a talk he
; is in that is not @self's. Hails are not counted: two men hailing one would each be worth less to the
; other the moment the other called, and they would take turns calling him every second.
(define-func partner-claims (?partner)
  (bind 0.0 ?claims)
  (bind (talk-of ?partner) ?theirs)
  (if (and (substantial ?theirs) (not (in-talk @self ?theirs)))
      (then (bind (+ /float (count (talk-participants ?theirs)) -1) ?claims)))
  ?claims)

; (hail-answer ?partner) - what ?partner answered @self's last hail of him: taken, turned-down, or @fail.
(define-func hail-answer (?partner)
  (bb-public-read-rec @self bbk-hail-answer ?partner answer))

; (answer-hail ?caller ?answer) - @self answers ?caller's hail ?answer, taken or turned-down.
(define-func answer-hail (?caller ?answer)
  (bb-public-write-rec ?caller bbk-hail-answer @self (/answer ?answer)))

; (taken-up-with ?partner) - a hail between @self and ?partner was taken up, whichever of them called
; it: ?partner answered @self's taken, or @self answered ?partner's.
(define-func taken-up-with (?partner)
  (or (eq (hail-answer ?partner) taken)
      (eq (bb-public-read-rec ?partner bbk-hail-answer @self answer) taken)))

; (take-up-into ?partner ?take-up) - @self takes ?partner's standing hail up by ?take-up: he holds his
; part in the talk it called him in, ?partner is on its board, his answer is on ?partner's board, and
; a turn-down of his own by ?partner is forgotten. @false when the hail no longer stands - it has
; ended and taken its record with it - or the talk seats no one more and ?partner is not on it.
(define-func take-up-into (?partner ?take-up)
  (bind (hail-talk ?partner @self) ?talk)
  (bind (and (substantial ?talk) (called-in ?talk)
             (or (in-talk ?partner ?talk) (not (talk-full ?talk))))
        ?seated)
  (if ?seated
      (then
        (join-talk ?talk ?take-up)
        (bb-public-add-member ?talk participant ?partner)
        (answer-hail ?partner taken)
        (bb-public-clear-rec @self bbk-hail-answer ?partner)))
  ?seated)

; (turned-down-by ?other) - ?other turned @self's last hail of him down.
(define-func turned-down-by (?other)
  (eq (hail-answer ?other) turned-down))

; (talks-with-lately ?other) - how many talks @self has begun with ?other within the last
; k-talk-again-window-seconds.
(define-func talks-with-lately (?other)
  (bind 0 ?count)
  (bind (time seconds) ?twl-now)
  (bind (- ?twl-now (seconds (k-talk-again-window-seconds) s)) ?twl-since)
  (for-each ?mine (every {? participant @self /during ?twl-since ?twl-now})
    (bind ?mine.subject ?talk)
    (if (and (<= (seconds-between ?twl-now (start-time ?mine)) (k-talk-again-window-seconds))
             (substantial (any {?talk participant ?other /ever})))
        (then (bind (+ ?count 1) ?count))))
  ?count)

; (caller-in ?talk) - the man calling @self in ?talk, as its record of him says, or @nothing.
(define-func caller-in (?talk)
  (flip (called-in ?talk) (bb-public-read-rec ?talk bbk-hail @self caller) @nothing))

; (standing-call ?caller ?called) - a call of ?caller's stands on ?called, unanswered or taken up.
(define-func standing-call (?caller ?called)
  (bind (hail-state ?caller ?called) ?state)
  (or (eq ?state called) (eq ?state taken)))

; (mutual-call ?partner) - @self and ?partner call each other: each has taken the other up, whether
; or not either has said so on the other's record - a man with no mind writes on none.
(define-func mutual-call (?partner)
  (and (standing-call @self ?partner) (standing-call ?partner @self)))

; (hail-accepted ?partner ?hail) - ?partner took up the call @self made in ?hail - by answering it, or
; by calling @self himself - and the two are in one talk.
(define-func hail-accepted (?partner ?hail)
  (and (in-one-talk ?partner @self)
       (or (eq (hail-state @self ?partner) taken) (mutual-call ?partner))))

; (hail-turned-down ?partner ?hail) - ?partner turned down the call @self made in ?hail.
(define-func hail-turned-down (?partner ?hail)
  (eq (hail-state @self ?partner) turned-down))

; (join-talk ?talk ?act) - @self takes part in ?talk: he joins its participant set, and he knows
; himself a party of it, caused by ?act that joins him, where it is held when he did not yet, and the
; occasion it is part of when he holds one for here today. Joining the talk he is in already changes
; nothing.
(define-func join-talk (?talk ?act)
  (bb-public-add-member ?talk participant @self)
  (if (unsubstantial (any {?talk participant @self}))
      (then (begin-belief {?talk participant @self /caused_by ?act})))
  (if (unsubstantial (any {?talk venue ?}))
      (then (begin-belief {?talk venue (spatial @self space)})))
  (bind (o /known [k occasion] {@o venue (spatial @self building)} {@o held-on (time date)}) ?occasion)
  (if (and (substantial ?occasion) (unsubstantial (any {?talk occasion ?})))
      (then (begin-belief {?talk occasion ?occasion}))))

; (open-talk) - a new talk, a shared object, for @self to join. Taking up a hail
; makes one when neither man is in a talk.
(define-func open-talk ()
  (share-object (o /invent [k talk])): ?talk
  ?talk)

; (talk-participants ?talk) - every party in ?talk: its participant set.
(define-func talk-participants (?talk)
  (bb-public-members ?talk participant))

; (out-of-call-of ?talk) - nobody else @self knows to be in ?talk would hear him call out: he has
; walked away from it.
(define-func out-of-call-of (?talk)
  (bind @true ?away)
  (for-each ?part (every {?talk participant ?})
    (if (and (neq ?part.target @self) (within-call ?part.target))
        (then (bind @false ?away) (break))))
  ?away)

; (other-party-in ?talk) - a party besides @self is in ?talk.
(define-func other-party-in (?talk)
  (bind @false ?still)
  (for-each ?party (talk-participants ?talk)
    (if (neq ?party @self)
        (then (bind @true ?still) (break))))
  ?still)

; (roster-lacks ?talk) - a party in ?talk is not yet a participant of it in @self's mind.
(define-func roster-lacks (?talk)
  (bind @false ?lacks)
  (for-each ?party (talk-participants ?talk)
    (if (unsubstantial (any {?talk participant ?party}))
        (then (bind @true ?lacks) (break))))
  ?lacks)

; (roster-add ?talk) - every party in ?talk takes part in it from now in @self's mind.
(define-func roster-add (?talk)
  (for-each ?party (talk-participants ?talk)
    (if (unsubstantial (any {?talk participant ?party}))
        (then (begin-belief {?talk participant ?party})))))

; (talk-full ?talk) - ?talk seats no one more (talk-size-max).
(define-func talk-full (?talk)
  (>= (count (talk-participants ?talk)) (talk-size-max)))

; (hailable ?partner) - @self may hail ?partner, THE gate on every hail: he is awake to hear it, his
; last word to @self did not turn him down - that man seeks @self out himself - he is in no
; talk, or in one that seats another, and @self is in none that seats no one more, since
; ?partner taking him up would join it.
(define-func hailable (?partner)
  (bind (talk-of ?partner) ?theirs)
  (and (not (attr-is ?partner awareness [k asleep]))
       (not (attr-is ?partner awareness [k unconscious]))
       (not (turned-down-by ?partner))
       (or (unsubstantial ?theirs) (not (talk-full ?theirs)))
       (not (in-full-talk))))

; (in-full-talk) - @self is in a talk that seats no one more.
(define-func in-full-talk ()
  (bind (talk-of @self) ?talk)
  (and (substantial ?talk) (talk-full ?talk)))

; (talk-between ?partner) - the talk @self and ?partner would talk in: ?partner's when he is
; in one with room, else @self's own with room, else @nothing - a new one. It is what every act of
; talking with ?partner happens within (scope), so a talk of his hosts it only when it is that one.
; While ?partner's seats no one more they cannot talk at all, and the act moves @self nowhere: it is
; within his own talk, where it waits or fails (hailable).
(define-func talk-between (?partner)
  (bind (talk-of ?partner) ?theirs)
  (bind (talk-of @self) ?mine)
  (cond (case (and (substantial ?theirs) (talk-full ?theirs)) ?mine)
        (case (substantial ?theirs) ?theirs)
        (case (and (substantial ?mine) (not (talk-full ?mine))) ?mine)
        (else @nothing)))

; (leave-talk ?talk) - @self leaves the talk ?talk: he comes off its participant
; and has-more sets, and his part in it and his knowing where it is held end. The last to leave
; lets it go (let-go-talk).
(define-func leave-talk (?talk)
  (if (substantial ?talk)
      (then
        (if (not (speaking))
            (then (turn-release ?talk)))
        (bb-public-remove-member ?talk participant @self)
        (bb-public-remove-member ?talk has-more @self)
        (end-belief {?talk participant @self})
        (end-belief {?talk venue ?})
        (let-go-talk ?talk))))

; (has-more-anywhere ?party) - a talk's has-more set still holds ?party.
(define-func has-more-anywhere (?party)
  (bind @false ?more)
  (for-each ?one (bb-public-every ? has-more ?party)
    (bind @true ?more)
    (break))
  ?more)

; A talk lasts until its parties have run out of things to say. What a man still has to
; say in one is his AGENDA, never stored: what his mind yields for it now (agenda-for). While it is
; not empty he shows it - he is in the talk's has-more set - and comes off it when it is
; (thinks/talk-has-more-think.mc).
; He is done with a talk when his agenda is empty and its has-more set is (said-all): the
; last to run out takes his leave, and his goodbye wakes the rest.

; (news-asked ?friend ?talk) - the last line in ?talk @self asked ?friend what is new with, or @nothing.
(define-func news-asked (?friend ?talk)
  (bind @nothing ?asked)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject @self) (eq ?line.auxiliary ?friend)
                   (matches ?line.target (qs ? (news-for ?..))))
              (then (bind ?line ?asked))))))
  ?asked)

; (asked-news ?friend ?talk) - @self has asked ?friend in ?talk what is new.
(define-func asked-news (?friend ?talk)
  (is-belief (news-asked ?friend ?talk)))

; (reply-of ?speaker ?said) - the line ?speaker said in reply to the line ?said: the one in the log of
; the talk ?said was said in whose message replies to it, or @nothing.
(define-func reply-of (?speaker ?said)
  (bind @nothing ?reply)
  (bind (said-in ?said) ?talk)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject ?speaker) (eq (replied-line ?line) ?said))
              (then (bind ?line ?reply) (break))))))
  ?reply)

; (replied ?speaker ?said) - ?speaker has replied to the line ?said.
(define-func replied (?speaker ?said)
  (is-belief (reply-of ?speaker ?said)))

; (last-line-from ?talk ?speaker) - the last line ?speaker said to @self in ?talk, or @nothing.
(define-func last-line-from (?talk ?speaker)
  (bind @nothing ?last)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject ?speaker) (eq ?line.auxiliary @self))
              (then (bind ?line ?last))))))
  ?last)

; (inquiry-of ?who ?fact) - the question @self asks ?who about what he wonders, ?fact: a fact clause
; is searched, (any ?fact) - the rest of a ghost's name, {G name >[n Tom]}, asks for the name alone,
; "Tom who?"; a ghost is asked after itself, which one it is, (which ?fact @self).
; When it is about a ghost ?who named to @self in an earlier talk, the question carries the context
; that tells him which one @self means: the line he said it in, "You told me Tom is ailing. Tom who?",
; or the document he wrote it in, "In your letter you wrote that Tom is ailing. Tom who?". A line said
; in the talk they are in now needs no quoting: the talk itself says which one.
(define-func inquiry-of (?who ?fact)
  (bind (cond (case (is-object ?fact) (qs /utterable [] (which ?fact @self)))
              (case (is-object (named-whom ?fact)) (qs /utterable [] (any ?fact).target))
              (else (qs /utterable [] (any ?fact))))
        ?qs)
  (bind (naming-line ?who ?fact) ?line)
  (cond (case (and (is-belief ?line) (not (said-in-our-talk ?line ?who)))
              (set-msg-rider ?qs context quote ?who ?line.target))
        (case (is-object ?line) (set-msg-rider ?qs context doc ?line))
        (else ?qs)))

; (named-whom ?fact) - the one whose name the fact clause ?fact is about, {G name ..}, or @nothing.
(define-func named-whom (?fact)
  (bind @nothing ?whom)
  (if (and (is-clause ?fact) (eq ?fact.label name))
      (then (bind ?fact.subject ?whom)))
  ?whom)

; (whom-asked ?asked) - the man a question or a wondering ?asked tells apart: the one asked after
; himself, (which ..), or the one whose name it asks the rest of; @nothing for any other.
(define-func whom-asked (?asked)
  (cond (case (is-object ?asked) ?asked)
        (else (named-whom ?asked))))

; (said-in-our-talk ?line ?who) - the line ?line @self heard was said in the talk he and ?who are in
; now.
(define-func said-in-our-talk (?line ?who)
  (bind (shared-talk ?who) ?talk)
  (and (substantial ?talk) (eq (said-in ?line) ?talk)))

; (prompting-line ?who ?qs) - the line ?who said to @self in the talk they are in now that named
; what the question ?qs asks about: asking it answers that line, "Tom is ailing" - "Which Tom?". What
; he meant by a then, there, he, she or it is asked of his last line, the one that left it unsaid or
; answered the one asked before: "Who was there?" - "Where do you mean?" - "The Red Lion" - "When do
; you mean?". @fail when ?who said none here.
(define-func prompting-line (?who ?qs)
  (bind (nth 1 (nth (k-msg-first-content-field) ?qs)) ?asked)
  (bind (flip (and (is-clause ?asked) (eq ?asked.label means))
              (last-line-from (shared-talk ?who) ?who)
              (naming-line ?who ?asked))
        ?line)
  (flip (and (is-belief ?line) (said-in-our-talk ?line ?who)) ?line @fail))

; (found-out ?fact) - @self knows what he wondered, ?fact: a fact clause he holds, or a ghost he no
; longer wonders about - it is identified.
(define-func found-out (?fact)
  (cond (case (is-object ?fact) (none {@self wonder ?fact}))
        (else (substantial (any ?fact)))))

; (askable ?who ?fact) - @self may ask ?who for the fact clause ?fact: he could know it, @self does
; not take him not to know it, and he has not refused to tell @self it.
(define-func askable (?who ?fact)
  (and (could-know ?who ?fact)
       (not (and (is-clause ?fact) (takes-not-to-know ?who (clausify ?fact /strip-interval))))
       (none {?who withhold ?fact @self})))

; (nobody-to-ask ?fact) - no man here could tell @self ?fact: none he is with is askable for it and
; either talking with him or hailable.
(define-func nobody-to-ask (?fact)
  (bind @true ?nobody)
  (for-each ?who (spatial (spatial @self space) contents [k human])
    (if (and (neq ?who @self)
             (spatial ?who co-located @self)
             (askable ?who ?fact)
             (or (conversing-with ?who) (hailable ?who)))
        (then (bind @false ?nobody) (break))))
  ?nobody)

; (wants-to-ask ?party) - @self wonders about something ?party could tell him.
(define-func wants-to-ask (?party)
  (bind @false ?asks)
  (for-each ?wonder (every {@self wonder ?})
    (if (askable ?party ?wonder.target)
        (then (bind @true ?asks) (break))))
  ?asks)

; WHAT @self TAKES OTHERS TO KNOW is held as who-knows entries, one of each fact - a clause with no
; interval - and each person, with the line that grounds it: (knows ?who ?fact) answers as (prob ..)
; does, (knows /not ..) whether he is taken NOT to know it, (knows .. /why) the line. A line marks
; every fact it carries, for its speaker and for everyone who heard it.

; (takes-to-know ?who ?fact) - @self takes ?who to know the fact clause ?fact.
(define-func takes-to-know (?who ?fact)
  (bind (knows ?who ?fact) ?held)
  (and (neq ?held @unknown) (neq ?held @false)))

; (takes-not-to-know ?who ?fact) - @self takes ?who NOT to know the fact clause ?fact: he said so.
(define-func takes-not-to-know (?who ?fact)
  (bind (knows /not ?who ?fact) ?held)
  (and (neq ?held @unknown) (neq ?held @false)))

; (mark-fact-told ?fact ?hearer ?SAY) - ?hearer, a person other than @self, knows ?fact by the line ?SAY.
(define-func mark-fact-told (?fact ?hearer ?SAY)
  (if (and (is-object ?hearer) (is-a ?hearer [k human]) (neq ?hearer @self))
      (then (set-knows ?hearer ?fact ?SAY))))

; (mark-fact-heard-by ?fact ?audience ?SAY) - everyone the line ?SAY reached knows ?fact: the man it
; was said to, the parties of the talk it was said to, and for a line said to nobody everyone @self
; holds to be within earshot of it.
(define-func mark-fact-heard-by (?fact ?audience ?SAY)
  (cond (case (unsubstantial ?audience)
              (for-each ?person (spatial (spatial @self space) contents [k human])
                (if (in-earshot ?person [k speech])
                    (then (mark-fact-told ?fact ?person ?SAY)))))
        (case (is-a ?audience [k talk])
              (for-each ?party (talk-participants ?audience)
                (mark-fact-told ?fact ?party ?SAY)))
        (else (mark-fact-told ?fact ?audience ?SAY))))

; (mark-item-told ?item ?audience ?SAY) - ?item, a belief or a clause the line ?SAY carried, is known
; by everyone it reached; anything else it carried marks nothing.
(define-func mark-item-told (?item ?audience ?SAY)
  (if (or (is-belief ?item) (is-clause ?item))
      (then (mark-fact-heard-by (clausify ?item /strip-interval) ?audience ?SAY))))

; (mark-told ?SAY ?audience) - the line ?SAY @self said to ?audience told everyone it reached every
; fact it carries, each one of a bundle of them apart. A question and an "I don't know" carry none.
(define-func mark-told (?SAY ?audience)
  (bind ?SAY.target ?msg)
  (if (and (matches ?msg (msg ?..)) (not (matches ?msg (msg ? @unknown))))
      (then
        (for-each ?sentence (msg-sentences ?msg)
          (if (is-list ?sentence)
              (then (for-each ?item ?sentence (mark-item-told ?item ?audience ?SAY)))
              (else (mark-item-told ?sentence ?audience ?SAY)))))))

; (mark-heard ?fact ?SAY) - the fact ?fact @self took from the line ?SAY he heard: its speaker knows
; it, and so does everyone else the line was said to.
(define-func mark-heard (?fact ?SAY)
  (bind (clausify ?fact /strip-interval) ?clause)
  (mark-fact-told ?clause ?SAY.subject ?SAY)
  (if (substantial ?SAY.auxiliary)
      (then (mark-fact-heard-by ?clause ?SAY.auxiliary ?SAY))))

; (teller-of ?belief) - the man whose line first told @self ?belief, or @nothing when no line did.
(define-func teller-of (?belief)
  (bind @nothing ?teller)
  (for-each ?source (sources ?belief)
    (if (and (is-belief ?source) (eq ?source.label SAY))
        (then (bind ?source.subject ?teller) (break))))
  ?teller)

; (speakable ?belief) - ?belief is a thing @self can say: a belief he holds, not forgotten, and still
; true now. Whatever is picked to be told - news, gossip, an aspect of himself - is speakable.
(define-func speakable (?belief)
  (and (is-belief ?belief) (eq (end-time ?belief) @ongoing)))

; (speech-worthy ?belief ?friend) - @self may tell ?friend the belief ?belief: it is speakable,
; ?friend is no party of it, its tier admits him, and @self does not take him to know it - he
; neither told it to @self, nor was told it by @self, nor heard it said.
(define-func speech-worthy (?belief ?friend)
  (and (speakable ?belief)
       (not (involved-in ?friend ?belief))
       (disclosable-to ?belief ?friend)
       (not (takes-to-know ?friend (clausify ?belief /strip-interval)))))

; (worthy-for ?belief ?audience) - @self may tell ?belief to someone in ?audience: the man himself,
; or any other party of the talk ?audience.
(define-func worthy-for (?belief ?audience)
  (bind @false ?worthy)
  (if (is-a ?audience [k human])
      (then (bind (speech-worthy ?belief ?audience) ?worthy))
      (else
        (for-each ?part (every {?audience participant ? /pres})
          (bind ?part.target ?party)
          (if (and (neq ?party @self) (speech-worthy ?belief ?party))
              (then (bind @true ?worthy) (break))))))
  ?worthy)

; (news-for ?audience) - the first piece of @self's news someone in ?audience (a man, or a talk) has
; not been told, or @nothing.
(define-func news-for (?audience)
  (bind @nothing ?pick)
  (for-each ?news (every {@self news ?})
    (if (worthy-for ?news.target ?audience)
        (then (bind ?news.target ?pick) (break))))
  ?pick)

; (disclosure-for ?other) - the first aspect of @self (a self-disclosable belief of his own: his
; interests, his kin, his work, where he is from) ?other does not know, or @nothing.
(define-func disclosure-for (?other)
  (bind @nothing ?pick)
  (for-each ?aspect (every {@self (facet-labels self-disclosable) ?})
    (if (speech-worthy ?aspect ?other)
        (then (bind ?aspect ?pick) (break))))
  ?pick)

; (gossip-worthy-for ?heard ?audience) - @self may pass the gossip ?heard on to someone in ?audience (a
; man, or a talk) who has not been told it: it is about someone @self can name, and not about @self.
(define-func gossip-worthy-for (?heard ?audience)
  (and (is-belief ?heard)
       (not (involved-in @self ?heard))
       (substantial (any {?heard.subject name ?}))
       (worthy-for ?heard ?audience)))

; (gossip-for ?audience) - the first piece of gossip @self may pass on to someone in ?audience, or
; @nothing.
(define-func gossip-for (?audience)
  (bind @nothing ?pick)
  (for-each ?gossip (every {@self gossip ?})
    (if (gossip-worthy-for ?gossip.target ?audience)
        (then (bind ?gossip.target ?pick) (break))))
  ?pick)

; (asked-and-answered ?friend ?talk) - @self asked ?friend what is new in ?talk and has his reply.
(define-func asked-and-answered (?friend ?talk)
  (bind (news-asked ?friend ?talk) ?asked)
  (and (is-belief ?asked) (replied ?friend ?asked)))

; (caught-up ?friend) - in a talk with ?friend, @self has told him all his news and has asked his.
(define-func caught-up (?friend)
  (bind (talk-of @self) ?talk)
  (and (substantial ?talk)
       (unsubstantial (news-for ?friend))
       (asked-and-answered ?friend ?talk)))

; (remarked-in ?talk) - @self has made his smalltalk remark in ?talk: one a talk.
(define-func remarked-in (?talk)
  (bind @false ?remarked)
  (for-each ?smalltalk (every {@self smalltalk ? ?talk /ever})
    (if (substantial (any {@self SAY (msg /smalltalk ? ?..) ? /succ /caused_by ?smalltalk}))
        (then (bind @true ?remarked) (break))))
  ?remarked)

; Every line said to a man makes a response from him relevant, and its kind decides which: a
; question an answer, an opening an opening's answer, a flirt a flirt's answer, a remark a remark
; or agreement, tidings tidings of his own or a receipt, a statement what he knew of it and felt
; about it. A response itself calls for none. The
; respond driver (drivers/respond-driver.mc) owes it, the respond task says it, caused by the line.

; (line-kind ?line) - the move @self takes the heard line ?line to make, a msg-class leaf
; (ontology/concepts.mon): its own move (msg-class), but a reply when it is tidings of a list or a
; line he construes (an insult): his answer to that is his reaction (reflexes/construe-speech.mc).
(define-func line-kind (?line)
  (bind ?line.target ?msg)
  (bind (msg-class ?msg) ?move)
  (cond (case (or (eq ?move question) (eq ?move opener) (eq ?move flirtation) (eq ?move smalltalk)) ?move)
        (case (matches ?msg (msg /tidings ? ~[?])) reply)
        (case (eq ?move tidings) tidings)
        (case (substantial (msg-construal ?msg)) reply)
        (case (substantial ?move) ?move)
        (else reply)))

; A LINE SAID TO A MAN IN A TALK HAS A REPLY STATE on his own board of that talk (bbk-reply-state,
; boards/talk.mc), written as he hears it (note-reply-state, called by the hear func) and settled at
; the head of each of his deliberations (tend-replies, the engine's /tend): a line its talk leaves a
; then, there, he, she or it unsaid in, or a statement about a man he must first ask which one he is,
; is blocked on that; he wonders what was meant by the first such, which has him ask back
; (drivers/ask-wonder-driver.mc); once nothing blocks it the line is heard again for what waited in
; it and, when its kind is owed a reply, is due: he is obliged to respond to it
; (drivers/respond-driver.mc). Lines that come due together are replied to oldest first. Presented,
; every owed line gets its reply; unpresented only a line owed wherever it is said.

; (question-begun ?inquire ?speaker) - the question of @self's inquire ?inquire of ?speaker is being
; said or is said: a hearer may answer it before its last word.
(define-func question-begun (?inquire ?speaker)
  (bind @false ?begun)
  (if (substantial (any {@self SAY ? ?speaker /ever /caused_by ?inquire}))
      (then (bind @true ?begun)))
  ?begun)

; (awaited-inquire ?speaker) - the inquire @self has made of ?speaker and still waits on: it runs and
; its question is begun; the first such, or @nothing.
(define-func awaited-inquire (?speaker)
  (bind @nothing ?awaited)
  (for-each ?inquire (every {@self inquire ?speaker ?})
    (if (question-begun ?inquire ?speaker)
        (then (bind ?inquire ?awaited) (break))))
  ?awaited)

; (owed-reply ?line) - the line ?line, heard now, is owed a reply by @self: its kind is owed wherever
; it is said (a question, a flirt), or, presented, owed from a party of the talk he is in - but not a
; statement that answers what he asked.
(define-func owed-reply (?line)
  (bind ?line.subject ?speaker)
  (bind (line-kind ?line) ?kind)
  (and (neq ?speaker @self)
       (not (and (eq ?kind statement) (is-belief (awaited-inquire ?speaker))))
       (or (has-facet ?kind answer-owed)
           (and (has-facet ?kind answer-owed-in-talk) (presented-lod) (in-one-talk @self ?speaker)))))

; (owe-reply ?line) - @self is obliged to respond to ?line now.
(define-func owe-reply (?line)
  (bind ?line.subject ?speaker)
  (if (none {@self obligation {@self respond ?speaker ?line} ?speaker})
      (then (begin-belief {@self obligation {@self respond ?speaker ?line} ?speaker}))))

; (note-reply-state ?SAY) - the line ?SAY just said to @self is given its reply state in the talk he
; shares with its speaker; outside one, a line owed a reply obliges him at once. @true when the line
; waits on what its speaker meant.
(define-func note-reply-state (?SAY)
  (bind ?SAY.subject ?speaker)
  (bind (shared-talk ?speaker) ?talk)
  (bind (tolerate (owed-reply ?SAY)) ?owed)
  (bind (tolerate (and (substantial ?talk) (not (empty (unresolved-in ?SAY))))) ?waits)
  (cond (case (and (substantial ?talk) ?owed) (bb-write-rec ?talk bbk-reply-state ?SAY (/state owed /blocked-on @nothing)))
        (case ?waits (bb-write-rec ?talk bbk-reply-state ?SAY (/state unowed /blocked-on @nothing)))
        (case ?owed (owe-reply ?SAY)))
  ?waits)

; (awaited-ghost ?line) - the man the statement ?line told @self about whom he wonders which of
; several he is, and could ask its speaker: "Tom is ailing" waits on "Which Tom?"; @nothing for none.
(define-func awaited-ghost (?line)
  (bind (told-fact ?line) ?fact)
  (cond (case (not (is-belief ?fact)) @nothing)
        (case (wondered-who ?fact.subject ?line.subject) ?fact.subject)
        (case (wondered-who ?fact.target ?line.subject) ?fact.target)
        (else @nothing)))

; (wondered-who ?thing ?speaker) - @self wonders which man ?thing is, or the rest of his name, and
; could ask ?speaker.
(define-func wondered-who (?thing ?speaker)
  (bind @false ?wondered)
  (if (is-object ?thing)
      (then
        (for-each ?wonder (every {@self wonder ?})
          (if (eq (whom-asked ?wonder.target) ?thing)
              (then (bind (askable ?speaker ?wonder.target) ?wondered) (break))))))
  ?wondered)

; (rehear-line ?SAY) - the line ?SAY that waited on what its speaker meant is heard again now that
; their talk says it: a question's people are noted, a statement's sentences that waited are adopted.
(define-func rehear-line (?SAY)
  (bind ?SAY.subject ?speaker)
  (bind (shared-talk ?speaker) ?talk)
  (if (matches ?SAY.target (qs ?..))
      (then (record-heard ?SAY ?talk))
      (else
        (bind (tolerate (adopt-msg /waited ?SAY ?talk)) ?out)
        (if (is-list ?out)
            (then (for-each ?fact ?out (absorb-heard-fact ?fact ?SAY)))
            (else (absorb-heard-fact ?out ?SAY))))))

; (blocked-on ?talk ?line) - what the line ?line of ?talk waits on in @self's mind: a then, there,
; he, she or it, a man he must ask about, or @nothing.
(define-func blocked-on (?talk ?line)
  (bb-read-rec ?talk bbk-reply-state ?line blocked-on))

; (settle-heard-line ?talk ?line ?state) - the line ?line of ?talk, heard and not yet due, is tested
; again: it waits on the first reference its talk leaves unsaid, or on the man he must ask about;
; else it is heard again when a reference held it and, owed a reply, is due.
(define-func settle-heard-line (?talk ?line ?state)
  (bind ?line.subject ?speaker)
  (bind (unresolved-in ?line) ?references)
  (bind (blocked-on ?talk ?line) ?was)
  (bind (flip (eq (line-kind ?line) statement) (awaited-ghost ?line) @nothing) ?ghost)
  (cond (case (not (empty ?references))
              (bind (head ?references) ?reference)
              (bb-write-rec ?talk bbk-reply-state ?line (/blocked-on ?reference)))
        (case (is-object ?ghost)
              (bb-write-rec ?talk bbk-reply-state ?line (/blocked-on ?ghost)))
        (else
          (if (and (substantial ?was) (not (is-object ?was)))
              (then (rehear-line ?line)))
          (if (eq ?state owed)
              (then
                (bb-write-rec ?talk bbk-reply-state ?line (/state due))
                (owe-reply ?line))
              (else (bb-clear-rec ?talk bbk-reply-state ?line))))))

; (waiting-line ?talk ?line) - the state of ?line in ?talk says it is heard and not yet due.
(define-func waiting-line (?talk ?line)
  (bind (bb-read-rec ?talk bbk-reply-state ?line state) ?state)
  (or (eq ?state owed) (eq ?state unowed)))

; (meaning-wanted ?talk ?speaker ?reference) - a line of ?speaker's in ?talk still waits on what he
; meant by ?reference.
(define-func meaning-wanted (?talk ?speaker ?reference)
  (bind @false ?wanted)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-read-keys ?talk bbk-reply-state)
          (if (and (waiting-line ?talk ?line) (eq ?line.subject ?speaker) (eq (blocked-on ?talk ?line) ?reference))
              (then (bind @true ?wanted) (break))))))
  ?wanted)

; (tend-replies) - at the head of each deliberation: every line of the talk @self is in that is heard
; and not yet due is settled, oldest first; a wonder about what a speaker meant ends once no line
; waits on it; and he wonders about the first reference the oldest waiting line leaves unsaid, one
; speaker's at a time. A line whose speaker has left the talk waits no more.
(define-func /tend tend-replies ()
  (bind (talk-of @self) ?talk)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-read-keys ?talk bbk-reply-state)
          (if (waiting-line ?talk ?line)
              (then
                (if (in-talk ?line.subject ?talk)
                    (then (settle-heard-line ?talk ?line (bb-read-rec ?talk bbk-reply-state ?line state)))
                    (else (bb-clear-rec ?talk bbk-reply-state ?line))))))))
  (for-each ?wonder (every {@self wonder {? means ? ?}})
    (bind ?wonder.target ?meant)
    (if (not (meaning-wanted ?talk ?meant.subject ?meant.target))
        (then (end-belief ?wonder))))
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-read-keys ?talk bbk-reply-state)
          (bind (blocked-on ?talk ?line) ?reference)
          (bind ?line.subject ?speaker)
          (if (and (waiting-line ?talk ?line) (substantial ?reference) (not (is-object ?reference))
                   (none {@self wonder {?speaker means ? ?}}))
              (then (wonder-meaning ?speaker ?reference)))))))

; (mark-reply-given ?line) - @self has replied to the line ?line: its reply state says so.
(define-func mark-reply-given (?line)
  (bind (said-in ?line) ?talk)
  (if (and (substantial ?talk) (substantial (bb-read-rec ?talk bbk-reply-state ?line state)))
      (then (bb-write-rec ?talk bbk-reply-state ?line (/state given)))))

; (reply-to ?line ?speaker) - the response @self gives ?speaker's heard line ?line, or @nothing.
(define-func reply-to (?line ?speaker)
  (bind ?line.target ?msg)
  (switch (line-kind ?line)
    (on question (answer-to ?msg ?speaker))
    (on flirtation (flirt-reply ?speaker))
    (on smalltalk (smalltalk-reply (talk-of @self)))
    (on tidings (tidings-reply ?speaker))
    (on statement (statement-reply ?line))
    (else @nothing)))

; (told-fact ?line) - the fact the heard line ?line told @self, as he holds it: of the beliefs its
; claims were adopted as, sourced from the line, the one he came to hold last - its first claim when
; he took them all as he heard it, the one that waited when a claim waited on what its speaker meant
; ("He is ailing" - "Who do you mean by he?" - "John Walker") - or @nothing when he took nothing.
(define-func told-fact (?line)
  (bind @nothing ?fact)
  (for-each ?content (msg-sentences ?line.target)
    (if (is-clause ?content)
        (then
          (bind ?content.label ?label)
          (bind (any {? ?label ? /sources ?line}) ?told)
          (if (and (is-belief ?told) (or (unsubstantial ?fact) (learned-before ?fact ?told)))
              (then (bind ?told ?fact))))))
  ?fact)

; (misfortune ?fact) - ?fact is a misfortune: a state whose value declares one (ailing, invalid).
(define-func misfortune (?fact)
  (bind ?fact.target ?value)
  (bind @false ?found)
  (if (is-kind ?value)
      (then
        (for-each ?construal (construals-of ?value)
          (if (eq ?construal misfortune-act)
              (then (bind @true ?found) (break))))))
  ?found)

; (courteous) - @self's manners have him show a sympathy he does not feel.
(define-func courteous ()
  (any {@self politeness ?politeness=0.5})
  (> ?politeness (k-courtesy-politeness)))

; (statement-reply ?line) - what @self answers a heard statement ?line with: a courtesy, never a
; claim - whether he knew the fact it told before the line (already-knew) or it is news to him
; (did-not-know), with what it made him feel, read off the feeling it caused
; (reflexes/reactions.mc), or, feeling nothing for a misfortune, the condolence a courteous man
; offers. A formulaic, so no hearer takes anything from it. @nothing when he took nothing from
; the line.
(define-func statement-reply (?line)
  (bind (told-fact ?line) ?fact)
  (bind @nothing ?reply)
  (if (is-belief ?fact)
      (then
        (bind (flip (learned-before ?fact ?line) already-knew did-not-know) ?knowing)
        (bind (any {@self emotion ? ? /caused_by ?fact}) ?emotion)
        (cond
          (case (is-belief ?emotion)
            (bind ?emotion.target ?feeling)
            (bind ?emotion.auxiliary ?whom)
            (bind (formulaic /reply [] ?knowing ?fact {@self emotion ?feeling ?whom}) ?reply))
          (case (and (misfortune ?fact) (courteous))
            (bind (formulaic /reply [] ?knowing ?fact condolence) ?reply))
          (else
            (bind (formulaic /reply [] ?knowing ?fact) ?reply)))))
  ?reply)

; (tidings-reply ?speaker) - what @self answers ?speaker's tidings with: tidings of his own the
; friend has not heard, else the receipt of them.
(define-func tidings-reply (?speaker)
  (bind @nothing ?news)
  (if (substantial (any {@self (closeness-labels friend) ?speaker}))
      (then (bind (news-for ?speaker) ?news)))
  (if (substantial ?news)
      (then (msg /utterable /tidings [] ?news))
      (else (formulaic [] response receipt))))

; (smalltalk-reply ?talk) - what @self answers a remark with in ?talk: his own remark, building on
; it, or having none, agreement.
(define-func smalltalk-reply (?talk)
  (bind (smalltalk-line ?talk) ?remark)
  (if (substantial ?remark)
      (then ?remark)
      (else (formulaic [] response agree))))

; (awaits-answer ?talk ?partner ?move) - the last line of the move ?move (a msg-class leaf) ?partner
; said to @self in ?talk is still unanswered.
(define-func awaits-answer (?talk ?partner ?move)
  (bind @nothing ?last)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject ?partner) (eq ?line.auxiliary @self) (eq (msg-class ?line.target) ?move))
              (then (bind ?line ?last))))))
  (and (is-belief ?last) (not (replied @self ?last))))

; (smalltalk-line ?talk) - the SMALLTALK remark @self has for ?talk, or @nothing: the weather he has
; seen, the first of it that is something, said once a talk: the weather of the town he stands in,
; which he says as "here".
(define-func smalltalk-line (?talk)
  (bind @nothing ?line)
  (bind (spatial @self town) ?here)
  (if (and (substantial ?here) (not (remarked-in ?talk)))
      (then
        (for-each ?weather (every {?here sky|rain|snow|fog|wind ?})
          (if (neq ?weather.target [k none])
              (then (bind (msg /utterable /smalltalk [] ?weather) ?line) (break))))))
  ?line)

; (flirted-in ?talk) - @self has made his flirt in ?talk: one a talk.
(define-func flirted-in (?talk)
  (bind @false ?flirted)
  (for-each ?flirt (every {@self flirt ? ?talk /ever})
    (if (substantial (any {@self SAY (formulaic ? compliment) ? /succ /caused_by ?flirt}))
        (then (bind @true ?flirted) (break))))
  ?flirted)

; (flirt-reply ?partner) - what @self answers a flirt of ?partner's with, his motives choosing: a flirt
; back to one he fancies, a rebuff - heard as the slight it is - to one he dislikes, else flattered.
(define-func flirt-reply (?partner)
  (if (substantial (any {@self fancy|desire|crave ?partner}))
      (then (formulaic [] return-compliment))
      (else
        (if (substantial (any {@self dislike|detest ?partner}))
            (then (formulaic [] manners-refusal))
            (else (formulaic [] response flattered))))))

; (agenda-for ?talk) - @self still has something to say in ?talk: a dialogue task of his still runs
; there, or a dialogue-line of some class is waiting for someone in it - the union over the classes.
(define-func agenda-for (?talk)
  (bind (or (substantial (any {@self smalltalk|flirt ? ?talk}))
            (and (substantial (any {@self unease ?talk})) (substantial (smalltalk-line ?talk))))
        ?more)
  (if (not ?more)
      (then
        (for-each ?party (talk-participants ?talk)
          (if (and (neq ?party @self)
                   (or (substantial (any {@self inquire|respond ?party ?}))
                       (substantial (any {@self catch-up|tell-gossip|get-acquainted ?party}))
                       (wants-to-ask ?party)
                       (substantial (news-for ?party))
                       (substantial (gossip-for ?party))))
              (then (bind @true ?more) (break))))))
  ?more)

; (said-all ?talk) - nobody in ?talk has anything left to say, @self included.
(define-func said-all (?talk)
  (if (substantial ?talk)
      (then (and (not (agenda-for ?talk)) (bb-public-none ?talk has-more)))
      (else @false)))

; (talked-out ?talk ?part) - nobody in ?talk has anything left to say (said-all), and a party of it
; has said something to @self since he took his part ?part in it: a talk nothing has been said in
; yet is not over.
(define-func talked-out (?talk ?part)
  (bind @false ?heard)
  (if (said-all ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (neq ?line.subject @self) (eq ?line.auxiliary @self) (happened-since ?line ?part))
              (then (bind @true ?heard) (break))))))
  ?heard)

; (asked-home) - the question @self is answering searched a home: the address that answers it is
; the answer itself, never "at home". The question is the line of the respond he runs.
(define-func asked-home ()
  (bind @false ?asked)
  (for-each ?respond (every {@self respond ? ?})
    (bind ?respond.auxiliary ?line)
    (if (and (is-belief ?line) (matches ?line.target (qs ?..)))
        (then
          (bind (nth 1 (nth (k-msg-first-content-field) ?line.target)) ?searched)
          (if (and (is-clause ?searched) (eq ?searched.label home))
              (then (bind @true ?asked) (break))))))
  ?asked)

; (self-home ?place) - ?place, an address as a line names it, is in the premises of @self's home - the
; home itself or a room of it - and the question it answers did not ask his home: the pack says it
; "at home" (Messages.mgr :: when:self-home).
(define-func self-home (?place)
  (bind @false ?own)
  (if (and (is-address ?place) (not (asked-home)))
      (then
        (for-each ?home (every {@self home ?})
          (if (same-premises (any {?home.target address ?}).target ?place)
              (then (bind @true ?own) (break))))))
  ?own)

; (self-home-room ?place ?room) - self-home, for the template that also says the room ?room.
(define-func self-home-room (?place ?room)
  (self-home ?place))

; (time-anchor-before ?episode) - the meal @self remembers ending within (time_anchor_hours) before
; ?episode began, the latest of them: what he reckons a time he no longer knows exactly from.
; @nothing when there is none.
(define-func time-anchor-before (?episode)
  (bind @nothing ?anchor)
  (bind (start-time ?episode) ?began)
  (for-each ?eat (every {@self eat ? ? /past})
    (bind (end-time ?eat) ?ended)
    (if (and (< ?ended ?began)
             (> ?ended (- ?began (seconds (time_anchor_hours) h)))
             (or (unsubstantial ?anchor) (> ?ended (end-time ?anchor))))
        (then (bind ?eat ?anchor))))
  ?anchor)

; (reckoned-time ?episode) - when @self says ?episode began: the clock he remembers, and, once he no
; longer knows it exactly, the line that reckons it from the meal before it - the clock and the meal,
; said "it was after my supper, so maybe ten o'clock?". A start he never saw is not known: the line
; says so and the clock he surely saw it at, "I don't know, but she had it on at eight".
(define-func reckoned-time (?episode)
  (bind (recalled-clock /start ?episode) ?clock)
  (bind (time-anchor-before ?episode) ?anchor)
  (cond (case (unknown ?clock)
          (bind (recalled-clock /start /seen ?episode) ?seen)
          (msg /utterable /reply [] @unknown ?seen ?episode))
        (case (or (remembered-exactly /start ?episode) (unsubstantial ?anchor)) ?clock)
        (else (bind (recalled-clock /start /told ?episode) ?told)
              (msg /utterable /reply [] ?told ?anchor))))

; (answer-to ?qs ?partner) - what @self says to ?partner's question ?qs: its content evaluated in
; his mind, or "nothing much" when it asked his news and he has none. What a man does is answered
; with the whole fact, whose it is as well as what: "I am a superintendent at the Land Registry".
; An answer he is less than sure of rides how sure he is ([/certainty @likely]).
(define-func answer-to (?qs ?partner)
  (bind (eval-msg /output_unknown_on_fail ?qs ?partner) ?answer)
  (bind (nth 1 (msg-content ?qs ?partner)) ?searched)
  (bind (answer-certainty ?qs ?partner) ?certainty)
  (cond
    (case (and (matches ?qs (qs ? (news-for ?..))) (unsubstantial ?answer))
      (formulaic [] response no-news))
    (case (and (is-clause ?searched) (eq ?searched.label job) (is-object ?answer))
      (answer-as-sure (msg /utterable /reply [] {?searched.subject job ?answer}) ?certainty))
    (case (matches ?answer (msg ?..))
      (answer-as-sure ?answer ?certainty))
    (else (answer-as-sure (msg /utterable /reply [] ?answer) ?certainty))))

; (answer-as-sure ?line ?certainty) - ?line as sure as @self is of it: a line he would swear to rides
; nothing, any other how sure he is.
(define-func answer-as-sure (?line ?certainty)
  (if (= ?certainty @true)
      (then ?line)
      (else (set-msg-rider ?line certainty ?certainty))))

; (focus-of ?talk) - whom @self faces in ?talk: the party he means to say a line to, else the first
; other party in it.
(define-func focus-of (?talk)
  (bind @nothing ?focus)
  (bind (any {@self intent {@self SAY ? ?}}) ?telling)
  (if (is-belief ?telling)
      (then
        (bind ?telling.target ?act)
        (bind ?act.auxiliary ?audience)
        (if (and (is-object ?audience) (in-talk ?audience ?talk))
            (then (bind ?audience ?focus)))))
  (if (unsubstantial ?focus)
      (then
        (for-each ?party (talk-participants ?talk)
          (if (neq ?party @self)
              (then (bind ?party ?focus) (break))))))
  ?focus)

; (can-hail ?thing) - the player can hail ?thing: a living man within (k-hail-reach) of him, as
; the world has it - the player holds no beliefs. The man hailed stays where he stands, so the
; player is the one who walks up. The host shows its Talk hint and lets T hail him on it.
(define-func can-hail (?thing)
  (and (is-a ?thing [k human])
       (neq (attr ?thing condition) [k dead])
       (< (distance (spatial @self bounds /env) (spatial ?thing bounds /env)) (k-hail-reach))))

; (engaged-here ?npc) - a hail between the player and ?npc was taken up, or the two call each other,
; and the player is still within earshot of his speaking voice: the host opens the dialogue on it.
(define-func engaged-here (?npc)
  (and (in-one-talk ?npc @self)
       (or (taken-up-with ?npc) (mutual-call ?npc))
       (in-earshot ?npc [k speech])))

; (player-caller) - the man calling the player: the one the record of the talk he is in names
; (caller-in), unless the player is calling that man himself - the two have then taken each other up;
; or @nothing. The host offers the player to take him up.
(define-func player-caller ()
  (bind (talk-of @self) ?talk)
  (bind (flip (substantial ?talk) (caller-in ?talk) @nothing) ?caller)
  (flip (and (substantial ?caller) (not (calling ?caller))) ?caller @nothing))

; (player-take-up ?npc) - the player takes up the hail ?npc called to him, as a man's take-up does
; (take-up-into): his answer is on ?npc's board, and what ?npc answered a hail of the player's own is
; forgotten. The answer is the line the player says back, the response ?npc's opening calls for
; (hail-response) as the reply to it, or @nothing when no opening stands.
(define-func player-take-up (?npc)
  (bind (hail-line ?npc @self) ?opening)
  (if (and (is-belief ?opening) (in-one-talk ?npc @self))
      (then
        (answer-hail ?npc taken)
        (set-hail-state ?npc taken)
        (bb-public-clear-rec @self bbk-hail-answer ?npc)
        (as-reply-to (hail-response ?opening.target) ?opening))
      (else @nothing)))

; (player-uncall ?npc) - the player's hail of ?npc is over: ?npc, who did not take it up, comes off
; the board of the talk the player is in, and the player with him when nobody else is on it.
(define-func player-uncall (?npc)
  (clear-hail ?npc)
  (bind (talk-of @self) ?talk)
  (if (and (substantial ?talk) (in-talk ?npc ?talk) (not (taken-up-with ?npc)))
      (then
        (bb-public-remove-member ?talk participant ?npc)
        (if (not (other-party-in ?talk))
            (then (bb-public-remove-member ?talk participant @self)))
        (let-go-talk ?talk))))

; (player-hail ?npc ?authority) - the player hails ?npc as a man's hail does (tasks/hail-task.mc):
; whoever else he called before and was not taken up by comes off his talk's board, and the hail is
; called in a talk from its first instant - ?npc's when he is in one, else the player's own or a
; new one, on whose board the player puts them both - and only ?npc taking it up brings ?npc to
; hold his part in it. A man already calling the player has his call taken by it: two who call each
; other have each taken the other up. The answer is the line he hails him with, its opening -
; plainly, or, when ?authority names the kind of his job, introducing himself by it.
(define-func player-hail (?npc ?authority)
  (bind (talk-of @self) ?standing)
  (if (substantial ?standing)
      (then
        (for-each ?called (talk-participants ?standing)
          (if (and (neq ?called @self) (neq ?called ?npc))
              (then (player-uncall ?called))))))
  (bb-public-clear-rec @self bbk-hail-answer ?npc)
  (clear-hail ?npc)
  (if (called-by ?npc)
      (then
        (set-hail-state ?npc taken)
        (answer-hail ?npc taken)))
  (if (unsubstantial (talk-of ?npc))
      (then
        (bind (talk-of @self) ?talk)
        (if (unsubstantial ?talk)
            (then
              (bind (open-talk) ?talk)
              (bb-public-add-member ?talk participant @self)))
        (bb-public-add-member ?talk participant ?npc)))
  (if (is-kind ?authority)
      (then (formulaic [] opening-phrase authority ?authority))
      (else (formulaic [] opening-phrase player_talk))))

; (owed-question ?party) - the question @self last put to ?party, or to the talk they are in now,
; that ?party has said nothing in reply to: what a line ?party says to him now answers, or @nothing.
; The host asks it of the man the player speaks to, and the player's line is caused by it.
(define-func owed-question (?party)
  (bind (shared-talk ?party) ?talk)
  (bind @nothing ?owed)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject @self)
                   (or (eq ?line.auxiliary ?party) (eq ?line.auxiliary ?talk))
                   (matches ?line.target (qs ?..))
                   (not (replied ?party ?line)))
              (then (bind ?line ?owed))))))
  ?owed)

; (player-line ?line ?owed) - ?line as the player says it: when it answers ?owed, the man's question
; he owes a reply (owed-question), a reply to it, as a man's own answer is (answer-to).
(define-func player-line (?line ?owed)
  (bind (nth 1 ?line) ?riders)
  (bind (nth 2 ?line) ?content)
  (cond (case (and (is-belief ?owed) (matches ?line (msg ?..)))
              (as-reply-to (msg /reply ?riders ?content) ?owed))
        (else ?line)))

; (player-leave-taking ?npc) - the player leaves the talk with ?npc, and the answer is
; the line he takes his leave with. He comes off its participant set, his hail of ?npc ends, and his
; answer to a hail of ?npc's goes.
(define-func player-leave-taking (?npc)
  (player-uncall ?npc)
  (bb-public-clear-rec ?npc bbk-hail-answer @self)
  (bind (talk-of @self) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-remove-member ?talk participant @self)
        (let-go-talk ?talk)))
  (formulaic [] leave-taking player_bye))
