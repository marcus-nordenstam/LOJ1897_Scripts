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
; A TALK is ONE object, shared (share-object): the opener invents it, and every participant
; holds his own copy of it, linked to the one the world keeps. Its public board is what keeps the
; group in step: its bbk-roster records are who is on it (talk-participants), each with his
; standing, and its has-more set who still has something to say. Joining writes his record and
; leaving clears it; a change to either wakes every participant reading it, busy or not, and each mirrors it in his own mind
; (talk-roster-join / -leave). When the last participant leaves, the board is empty and the
; world lets the talk go. What a man knows of a talk
; is his own beliefs, kept to the board: {<talk> participant <participant>} for each participant, one
; interval per spell (talk-roster-join / -leave), {<talk> venue <space>} while he is in
; it, {<talk> occasion <occasion>} when it is part of one.
;
; A HAIL is a man hailing @self into a talk, the same at both levels of detail and kept on the
; boards. It is made IN a talk from its first instant: the one @self is in, else the hailer's
; own, else a new one the hailer makes, on whose board he puts both of them
; (hail-into-talk) - so whoever speaks to either of them finds one talk and waits for its turn.
; A man's STANDING in a talk is on his record on its board (bbk-roster, boards/talk.mc): hailed
; while a hail has put him there, in once he holds his part in it, which each man writes for himself
; (join-talk) - @self as he takes the hail up, the hailer once it is taken up. The hail is MADE by
; its opening, a (formulaic opening-phrase ..) said to @self to its end: from then the talk's record
; of him (bbk-hail) says he is hailed and by whom (hailer-in). He answers on that record - taken as
; he takes it up, turned-down as he refuses or rebuffs it - and the hailer clears it when his hail is
; over. It is always answered, and how is his choice: he takes up the talk, declines it for what he
; is busy with, or rebuffs a man he despises (drivers/answer-hail-driver.mc). A hail that ends
; without being taken up takes off the board whoever is still only hailed there (unseat-hailed).
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

; (in-shouting-distance ?listener) - ?listener would hear @self shout, as @self knows where he
; stands - seen, or heard: a sound places the man it came from.
(define-func in-shouting-distance (?listener)
  (in-earshot ?listener [k shout]))

; (msg-in-earshot ?listener ?msg) - ?listener would hear @self say ?msg: a person within earshot,
; a talk when every participant @self knows to be in it is. tell closes on its audience until
; this holds.
(define-func msg-in-earshot (?listener ?msg)
  (if (and (is-object ?listener) (is-a ?listener [k talk]))
      (then (unsubstantial (participant-out-of-earshot ?listener ?msg)))
      (else (in-earshot ?listener (voice-sound ?msg)))))

; (participant-out-of-earshot ?talk ?msg) - a participant on the board of the talk ?talk who would not hear @self
; say ?msg where he stands, or @nothing - as for an audience that is no talk.
(define-func participant-out-of-earshot (?talk ?msg)
  (bind @nothing ?far)
  (if (and (is-object ?talk) (is-a ?talk [k talk]))
      (then
        (for-each ?who (talk-participants ?talk)
          (if (and (neq ?who @self) (not (in-earshot ?who (voice-sound ?msg))))
              (then (bind ?who ?far) (break))))))
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

; (hail-response ?opening) - the response a hail's opening asks for: a man who introduced
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

; (taking-up ?hailer) - @self has begun taking up ?hailer's talk.
(define-func taking-up (?hailer)
  (substantial (any {@self take-up ?hailer})))

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

; (talk-of ?participant) - the talk whose board holds ?participant, or @nothing. A
; man takes part in one talk at a time.
(define-func talk-of (?participant)
  (bind @nothing ?talk)
  (for-each ?one (bb-public-every ? bbk-roster ?participant)
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

; (in-talk ?participant ?talk) - ?talk's board holds ?participant, hailed or in.
(define-func in-talk (?participant ?talk)
  (and (substantial ?talk) (substantial (bb-public-any ?talk bbk-roster ?participant))))

; (standing-in ?talk ?participant) - ?participant's standing on ?talk's board: hailed, in, or @fail when he is not
; on it.
(define-func standing-in (?talk ?participant)
  (bb-public-read-rec ?talk bbk-roster ?participant standing))

; (holds-part ?participant ?talk) - ?participant holds his part in ?talk: his standing there is in.
(define-func holds-part (?participant ?talk)
  (and (substantial ?talk) (eq (standing-in ?talk ?participant) in)))

; (seat ?talk ?participant) - ?participant is on ?talk's board from now, hailed, unless he is on it already.
(define-func seat (?talk ?participant)
  (if (not (in-talk ?participant ?talk))
      (then (bb-public-write-rec ?talk bbk-roster ?participant (/standing hailed)))))

; (unseat ?talk ?participant) - ?participant comes off ?talk's board when he is only hailed there.
(define-func unseat (?talk ?participant)
  (if (eq (standing-in ?talk ?participant) hailed)
      (then (bb-public-clear-rec ?talk bbk-roster ?participant))))

; (shared-talk ?participant) - the talk @self and ?participant both take part in, or @nothing: the
; discourse a line ?participant says to him belongs to. A line overheard from a talk he is not in has none.
(define-func shared-talk (?participant)
  (flip (in-one-talk @self ?participant) (talk-of @self) @nothing))

; A LINE SAID TO A MAN IN A TALK IS SAID IN THAT TALK, and the talk's log (bbk-line, boards/talk.mc)
; records it. The line it replies to rides on its message (the reply-to rider): that is how a reply
; is told from its line, in either mind. A hail puts the man it hails in a talk before its opening is said, so an opening is logged
; like any line. A reply goes into the talk of the line it replies to. A line to a man in no talk -
; nobody has hailed him - is in none and is logged nowhere.

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
; says he is hailed, by @self (bbk-hail, boards/talk.mc).
(define-func record-line (?SAY ?audience)
  (bind (line-talk ?audience (replied-line ?SAY)) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-write-rec ?talk bbk-line ?SAY [])
        (if (and (is-object ?audience) (is-a ?audience [k human])
                 (matches ?SAY.target (formulaic ? opening-phrase ?..)))
            (then (bb-public-write-rec ?talk bbk-hail ?audience (/hailer @self /state hailed /line ?SAY))))))
  ?talk)

; (hail-talk ?hailer ?hailed) - the talk whose board holds ?hailer's hail of ?hailed (bbk-hail), or
; @nothing.
(define-func hail-talk (?hailer ?hailed)
  (bind @nothing ?found)
  (for-each ?talk (bb-public-every ? bbk-hail ?hailed)
    (if (eq (bb-public-read-rec ?talk bbk-hail ?hailed hailer) ?hailer)
        (then (bind ?talk ?found) (break))))
  ?found)

; (hail-state ?hailer ?hailed) - the state of ?hailer's hail of ?hailed: hailed, taken or turned-down,
; or @nothing when none stands.
(define-func hail-state (?hailer ?hailed)
  (bind (hail-talk ?hailer ?hailed) ?talk)
  (cond (case (unsubstantial ?talk) @nothing)
        (else (bb-public-read-rec ?talk bbk-hail ?hailed state))))

; (set-hail-state ?hailer ?state) - @self answers ?hailer's hail of him: its record says ?state, taken
; or turned-down. A hail that no longer stands has no record to answer.
(define-func set-hail-state (?hailer ?state)
  (bind (hail-talk ?hailer @self) ?talk)
  (if (substantial ?talk)
      (then (bb-public-write-rec ?talk bbk-hail @self (/state ?state)))))

; (hail-line ?hailer ?hailed) - the opening ?hailer hailed ?hailed with, as @self holds it, or
; @nothing when no hail of his stands or @self did not hear it.
(define-func hail-line (?hailer ?hailed)
  (bind (hail-talk ?hailer ?hailed) ?talk)
  (bind @nothing ?line)
  (if (substantial ?talk)
      (then (bind (bb-public-read-rec ?talk bbk-hail ?hailed line) ?line)))
  (flip (is-belief ?line) ?line @nothing))

; (hailed-in ?talk) - @self is hailed in ?talk and has not answered.
(define-func hailed-in (?talk)
  (eq (bb-public-read-rec ?talk bbk-hail @self state) hailed))

; (hailing ?partner) - a hail of @self's stands on ?partner, answered or not.
(define-func hailing (?partner)
  (substantial (hail-state @self ?partner)))

; (hailed-by ?partner) - a hail of ?partner's stands on @self, unanswered.
(define-func hailed-by (?partner)
  (eq (hail-state ?partner @self) hailed))

; (saying-opening ?partner) - an opening of @self's to ?partner is on his mouth.
(define-func saying-opening (?partner)
  (substantial (any {@self SAY (formulaic ? opening-phrase ?..) ?partner})))

; (clear-hail ?hailed) - @self's hail of ?hailed is over: its record goes.
(define-func clear-hail (?hailed)
  (bind (hail-talk @self ?hailed) ?talk)
  (if (substantial ?talk)
      (then (bb-public-clear-rec ?talk bbk-hail ?hailed))))

; (let-go-talk ?talk) - when nobody is on ?talk's board any more its log goes, and with it the board
; that keeps the talk.
(define-func let-go-talk (?talk)
  (if (and (substantial ?talk) (empty (talk-participants ?talk)))
      (then (bb-public-clear ?talk bbk-line))))

; (hail-into-talk ?partner) - @self's hail of ?partner is made in a talk from now: ?partner's when he
; is in one, where @self waits for its turn like anyone; else @self's own, or a new one he makes and
; goes on the board of, which he puts ?partner on the board of, both hailed there. Whoever speaks to ?partner from now finds him in that talk.
(define-func hail-into-talk (?partner)
  (if (unsubstantial (talk-of ?partner))
      (then
        (bind (talk-of @self) ?talk)
        (if (unsubstantial ?talk)
            (then
              (bind (open-talk) ?talk)
              (seat ?talk @self)))
        (seat ?talk ?partner))))

; (leave-seat ?participant) - ?participant comes off the board of the talk he is on when he is only hailed there,
; and a talk nobody is left on is let go.
(define-func leave-seat (?participant)
  (bind (talk-of ?participant) ?talk)
  (if (substantial ?talk)
      (then
        (unseat ?talk ?participant)
        (let-go-talk ?talk))))

; (unseat-hailed ?partner) - @self's hail of ?partner is over: whichever of the two is still only hailed on
; the board of the talk he is on comes off it. A man who holds his part in a talk stays. One hail
; stands on a man at a time (the hail's sync), so a man still only hailed was put there by this one.
(define-func unseat-hailed (?partner)
  (leave-seat ?partner)
  (leave-seat @self))

; (in-one-talk ?participant ?partner) - both are on one talk's board: a talk they share or one of them
; hailed the other into, not yet a talk between them (conversing-with).
(define-func in-one-talk (?participant ?partner)
  (in-talk ?partner (talk-of ?participant)))

; A LINE IN A TALK TAKES ITS TURN: one man at a time speaks in a talk, the rest wait for its turn,
; and the man who is done hands it on (turn-request, holds-turn, turn-release - the engine's). A
; turn is a talk's and nothing else's, so a line needs one board at most: a line to a talk, or to a
; man in one, takes that talk's turn. EVERY LINE TO A MAN OR A TALK TAKES ONE: a man in no talk is
; not spoken to until a hail has put him in one (drivers/say-driver.mc). Only a broadcast, a line
; to nobody in particular, takes none. A reply takes its turn like any line and goes first of those waiting (line-rank), so
; it is said once the line it replies to is over; of the others the man longest since he last
; spoke goes first. A man spoken to in his talk stays where he is (heed-speaker).

; (turn-board ?audience) - the talk whose turn a line to ?audience takes: ?audience itself when it is
; a talk; for a man the talk the two are on the board of, else the one he is on, else the one his
; hail of @self stands in - @self answering a hailer who stands outside it. @nothing for a
; broadcast, which takes no turn, and for a man no talk reaches, who cannot be spoken to yet.
(define-func turn-board (?audience)
  (cond (case (unsubstantial ?audience) @nothing)
        (case (is-a ?audience [k talk]) ?audience)
        (case (in-one-talk @self ?audience) (talk-of @self))
        (case (substantial (talk-of ?audience)) (talk-of ?audience))
        (else (hail-talk ?audience @self))))

; (addressable ?audience) - a line to ?audience has a talk to be said in, or is a broadcast and
; needs none.
(define-func addressable (?audience)
  (or (unsubstantial ?audience) (substantial (turn-board ?audience))))

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

; (my-turn ?audience) - @self may speak to ?audience now: the line is a broadcast, or he holds the
; turn of the talk it takes. A man no talk reaches he may not speak to.
(define-func my-turn (?audience)
  (bind (turn-board ?audience) ?board)
  (cond (case (unsubstantial ?audience) @true)
        (case (unsubstantial ?board) @false)
        (else (holds-turn ?board))))

; (line-waits-on ?board) - @self means to say a line that takes the turn of the talk ?board.
(define-func line-waits-on (?board)
  (bind @false ?waits)
  (for-each ?intent (every {@self intent {@self SAY ? ?}})
    (bind ?intent.target ?act)
    (if (eq (turn-board ?act.auxiliary) ?board)
        (then (bind @true ?waits) (break))))
  ?waits)

; (spoken-to) - another man holds the turn of the talk @self is in.
(define-func spoken-to ()
  (bind (talk-of @self) ?talk)
  (and (substantial ?talk) (turn-held-by-another ?talk)))

; (speaking) - a line of @self's is being said: his SAY runs, and it holds his turn until it ends
; however it ends, whatever became of the intent behind it.
(define-func speaking ()
  (substantial (any {@self SAY ?})))

; (taken-between ?partner) - a hail between @self and ?partner stands taken up, whichever of them
; hailed it, or the two hail each other.
(define-func taken-between (?partner)
  (or (eq (hail-state @self ?partner) taken)
      (eq (hail-state ?partner @self) taken)
      (mutual-hail ?partner)))

; (conversing-with ?partner) - @self and ?partner talk together: @self holds his part in a talk, and
; ?partner holds his in it too, or is on its board with his hail of @self taken up and his own part
; his to take as that hail ends. Being on one talk's board with a man is not yet talking to him.
(define-func conversing-with (?partner)
  (bind (talk-of @self) ?talk)
  (and (holds-part @self ?talk)
       (in-talk ?partner ?talk)
       (or (holds-part ?partner ?talk)
           (eq (hail-state ?partner @self) taken))))

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

; (partner-claims ?partner) - how many other men already hold ?partner: the other participants of a talk he
; is in that is not @self's. Hails are not counted: two men hailing one would each be worth less to the
; other the moment the other hailed, and they would take turns hailing him every second.
(define-func partner-claims (?partner)
  (bind 0.0 ?claims)
  (bind (talk-of ?partner) ?theirs)
  (if (and (substantial ?theirs) (not (in-talk @self ?theirs)))
      (then (bind (+ /float (count (talk-participants ?theirs)) -1) ?claims)))
  ?claims)

; (take-up-into ?partner ?take-up) - @self takes ?partner's standing hail up by ?take-up: he holds his
; part in the talk it hailed him in, ?partner is on its board - hailed, until he takes his own part
; as his hail ends taken up - and a turn-down of his own by ?partner is forgotten. @false when the hail no longer stands - it has
; ended and taken its record with it - or the talk seats no one more and ?partner is not on it.
(define-func take-up-into (?partner ?take-up)
  (bind (hail-talk ?partner @self) ?talk)
  (bind (and (substantial ?talk) (hailed-in ?talk)
             (seat-for ?talk ?partner))
        ?seated)
  (if ?seated
      (then
        (join-talk ?talk ?take-up)
        (seat ?talk ?partner)
        (forget-turned-down ?partner)))
  ?seated)

; (note-turned-down ?other) - @self remembers that ?other turned his hail down now.
(define-func note-turned-down (?other)
  (bb-write-rec @self bbk-turned-down ?other (/at (time seconds))))

; (forget-turned-down ?other) - @self no longer holds ?other's turn-down against hailing him.
(define-func forget-turned-down (?other)
  (bb-clear-rec @self bbk-turned-down ?other))

; (turned-down-by ?other) - ?other turned a hail of @self's down within the last
; k-turned-down-seconds: @self does not hail him, and waits for him to hail.
(define-func turned-down-by (?other)
  (bind (bb-read-rec @self bbk-turned-down ?other at) ?at)
  (cond (case (unsubstantial ?at) @false)
        (else (< (seconds-between (time seconds) ?at) (k-turned-down-seconds)))))

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

; (hailer-in ?talk) - the man hailing @self in ?talk, as its record of him says, or @nothing.
(define-func hailer-in (?talk)
  (flip (hailed-in ?talk) (bb-public-read-rec ?talk bbk-hail @self hailer) @nothing))

; (standing-hail ?hailer ?hailed) - a hail of ?hailer's stands on ?hailed, unanswered or taken up.
(define-func standing-hail (?hailer ?hailed)
  (bind (hail-state ?hailer ?hailed) ?state)
  (or (eq ?state hailed) (eq ?state taken)))

; (mutual-hail ?partner) - @self and ?partner hail each other: each has taken the other up, whether
; or not either has said so on the other's record - a man with no mind writes on none.
(define-func mutual-hail (?partner)
  (and (standing-hail @self ?partner) (standing-hail ?partner @self)))

; (hail-accepted ?partner ?hail) - ?partner took up the hail @self made in ?hail - by answering it, or
; by hailing @self himself - and the two are in one talk.
(define-func hail-accepted (?partner ?hail)
  (and (in-one-talk ?partner @self)
       (or (eq (hail-state @self ?partner) taken) (mutual-hail ?partner))))

; (hail-turned-down ?partner ?hail) - ?partner turned down the hail @self made in ?hail.
(define-func hail-turned-down (?partner ?hail)
  (eq (hail-state @self ?partner) turned-down))

; (join-talk ?talk ?act) - @self takes part in ?talk: his standing on its board is in, and he knows
; himself a participant of it, caused by ?act that joins him, where it is held when he did not yet, and the
; occasion it is part of when he holds one for here today. Joining the talk he is in already changes
; nothing.
(define-func join-talk (?talk ?act)
  (bb-public-write-rec ?talk bbk-roster @self (/standing in))
  (if (unsubstantial (any {?talk participant @self}))
      (then
        (begin-belief {?talk participant @self /caused_by ?act})))
  (discharge-hails-owed ?talk ?act.target)
  (if (unsubstantial (any {?talk venue ?}))
      (then (begin-belief {?talk venue (spatial @self space)})))
  (bind (o /known [k occasion] {@o venue (spatial @self building)} {@o held-on (time date)}) ?occasion)
  (if (and (substantial ?occasion) (unsubstantial (any {?talk occasion ?})))
      (then (begin-belief {?talk occasion ?occasion}))))

; AN OBLIGATION OF TALK IS BEGUN AND ENDED BY THE TASK WHOSE ACT DOES IT. A man who turns a hail
; down because he is busy - in another talk, or at something keener - owes the man who hailed him a
; hail of his own once he is free (drivers/hail-obligation-driver.mc); turned down weary of
; company, or rebuffed, he owes him nothing; talking with him, by either man's hail, discharges it.
; A reply he owes is no obligation of this kind: it lives on the line's record in the talk it was
; said in, and goes with that talk (bbk-line, boards/talk.mc).

; (busy-refusal ?reason) - a refusal's reason says @self was busy: the act that outbid the hail, or
; the talk he was in - never weariness of company.
(define-func busy-refusal (?reason)
  (cond (case (is-relation ?reason) @true)
        (else (not (eq ?reason weary)))))

; (owe-hail-back ?hailer ?msg ?turn-down) - @self, having turned ?hailer's hail down with ?msg by
; ?turn-down, owes him a hail of his own when ?msg was a busy man's refusal and he owes none yet.
(define-func owe-hail-back (?hailer ?msg ?turn-down)
  (if (and (matches ?msg (formulaic ? refusal ?..))
           (busy-refusal (nth (k-formulaic-key-field) ?msg))
           (none {@self obligation {@self hail ?hailer} ?hailer}))
      (then (begin-belief {@self obligation {@self hail ?hailer} ?hailer /caused_by ?turn-down}))))

; (discharge-hails-owed ?talk ?partner) - @self, taking his part in ?talk, no longer owes a hail to
; ?partner, whose hail or whose taking up brought him into it, nor to any man who holds his part in it.
(define-func discharge-hails-owed (?talk ?partner)
  (for-each ?owed (every {@self obligation {@self hail ?} ?})
    (bind ?owed.auxiliary ?hailer)
    (if (or (eq ?hailer ?partner) (holds-part ?hailer ?talk))
        (then (end-belief ?owed)))))

; (reply-settled ?speaker ?line) - @self has responded to ?speaker's line ?line: its record no longer
; says a reply is owed.
(define-func reply-settled (?speaker ?line)
  (bind (said-in ?line) ?talk)
  (if (and (substantial ?talk) (substantial (bb-public-read-rec ?talk bbk-line ?line reply)))
      (then (bb-public-write-rec ?talk bbk-line ?line (/reply @nothing)))))

; (open-talk) - a new talk, a shared object, for @self to join. Taking up a hail
; makes one when neither man is in a talk.
(define-func open-talk ()
  (share-object (o /invent [k talk])): ?talk
  ?talk)

; (talk-participants ?talk) - every participant on ?talk's board, hailed or in.
(define-func talk-participants (?talk)
  (bb-public-members ?talk bbk-roster))

; (out-of-shouting-distance ?talk) - nobody else on ?talk's board would hear @self shout: he has walked
; away from it.
(define-func out-of-shouting-distance (?talk)
  (bind @true ?away)
  (for-each ?participant (talk-participants ?talk)
    (if (and (neq ?participant @self) (in-shouting-distance ?participant))
        (then (bind @false ?away) (break))))
  ?away)

; (other-participant-in ?talk) - a participant besides @self is in ?talk.
(define-func other-participant-in (?talk)
  (bind @false ?still)
  (for-each ?participant (talk-participants ?talk)
    (if (neq ?participant @self)
        (then (bind @true ?still) (break))))
  ?still)

; (roster-lacks ?talk) - a participant in ?talk is not yet a participant of it in @self's mind.
(define-func roster-lacks (?talk)
  (bind @false ?lacks)
  (for-each ?participant (talk-participants ?talk)
    (if (unsubstantial (any {?talk participant ?participant}))
        (then (bind @true ?lacks) (break))))
  ?lacks)

; (roster-add ?talk) - every participant in ?talk takes part in it from now in @self's mind.
(define-func roster-add (?talk)
  (for-each ?participant (talk-participants ?talk)
    (if (unsubstantial (any {?talk participant ?participant}))
        (then (begin-belief {?talk participant ?participant})))))

; (talk-full ?talk) - ?talk seats no one more (talk-size-max).
(define-func talk-full (?talk)
  (>= (count (talk-participants ?talk)) (talk-size-max)))

; (seat-for ?talk ?participant) - ?talk has a seat for ?participant: he is on its board already, a hail having
; put him there, or it seats one more.
(define-func seat-for (?talk ?participant)
  (or (in-talk ?participant ?talk) (not (talk-full ?talk))))

; (room-with ?partner) - @self is in no talk, or in one with a seat for ?partner.
(define-func room-with (?partner)
  (bind (talk-of @self) ?talk)
  (or (unsubstantial ?talk) (seat-for ?talk ?partner)))

; (hailable ?partner) - @self may hail ?partner, THE gate on every hail: he is awake to hear it, his
; last word to @self did not turn him down - that man seeks @self out himself - he is in no
; talk, or in one with a seat for @self, and @self is in none without a seat for him, since
; ?partner taking him up would join it.
(define-func hailable (?partner)
  (bind (talk-of ?partner) ?theirs)
  (and (not (attr-is ?partner awareness [k asleep]))
       (not (attr-is ?partner awareness [k unconscious]))
       (not (turned-down-by ?partner))
       (or (unsubstantial ?theirs) (seat-for ?theirs @self))
       (room-with ?partner)))

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

; (leave-talk ?talk) - @self leaves the talk ?talk: he comes off its board and its
; has-more set, the lines said to him there are owed and wait for nothing more, and his part in
; it and his knowing where it is held end. The last to leave lets it go (let-go-talk).
(define-func leave-talk (?talk)
  (if (substantial ?talk)
      (then
        (if (not (speaking))
            (then (turn-release ?talk)))
        (settle-lines-to-me ?talk)
        (bb-public-clear-rec ?talk bbk-roster @self)
        (bb-public-remove-member ?talk has-more @self)
        (end-belief {?talk participant @self})
        (end-belief {?talk venue ?})
        (let-go-talk ?talk))))

; (has-more-anywhere ?participant) - a talk's has-more set still holds ?participant.
(define-func has-more-anywhere (?participant)
  (bind @false ?more)
  (for-each ?one (bb-public-every ? has-more ?participant)
    (bind @true ?more)
    (break))
  ?more)

; A talk lasts until its participants have run out of things to say. What a man still has to
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

; (replied-out-of-order ?line) - @self has already replied to a line said after ?line in the talk
; ?line was said in: a reply to ?line now comes out of the order the lines were said in.
(define-func replied-out-of-order (?line)
  (bind @false ?past)
  (bind @false ?out)
  (bind (said-in ?line) ?talk)
  (if (substantial ?talk)
      (then
        (for-each ?later (bb-public-read-keys ?talk bbk-line)
          (cond (case (eq ?later ?line) (bind @true ?past))
                (case (and ?past (neq ?later.subject @self) (replied @self ?later))
                      (bind @true ?out) (break))))))
  ?out)

; (prefaced ?reply ?line) - the reply ?reply to the line ?line, as it is said: out of order
; (replied-out-of-order) it carries, as its context, the line it replies to - the question he was
; asked or what he was told - said before it as a sentence of its own. The wording is the pack's
; (:CONTEXT, Messages.mgr).
(define-func prefaced (?reply ?line)
  (cond (case (not (replied-out-of-order ?line)) ?reply)
        (case (matches ?line.target (qs ?..)) (set-msg-rider ?reply context asked ?line.subject ?line.target))
        (else (set-msg-rider ?reply context quote ?line.subject ?line.target))))

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

; (wants-to-ask ?participant) - @self wonders about something ?participant could tell him.
(define-func wants-to-ask (?participant)
  (bind @false ?asks)
  (for-each ?wonder (every {@self wonder ?})
    (if (askable ?participant ?wonder.target)
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
; was said to, the participants of the talk it was said to, and for a line said to nobody everyone @self
; holds to be within earshot of it.
(define-func mark-fact-heard-by (?fact ?audience ?SAY)
  (cond (case (unsubstantial ?audience)
              (for-each ?person (spatial (spatial @self space) contents [k human])
                (if (in-earshot ?person [k speech])
                    (then (mark-fact-told ?fact ?person ?SAY)))))
        (case (is-a ?audience [k talk])
              (for-each ?participant (talk-participants ?audience)
                (mark-fact-told ?fact ?participant ?SAY)))
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
; ?friend is no participant of it, its tier admits him, and @self does not take him to know it - he
; neither told it to @self, nor was told it by @self, nor heard it said.
(define-func speech-worthy (?belief ?friend)
  (and (speakable ?belief)
       (not (involved-in ?friend ?belief))
       (disclosable-to ?belief ?friend)
       (not (takes-to-know ?friend (clausify ?belief /strip-interval)))))

; (worthy-for ?belief ?audience) - @self may tell ?belief to someone in ?audience: the man himself,
; or any other participant of the talk ?audience.
(define-func worthy-for (?belief ?audience)
  (bind @false ?worthy)
  (if (is-a ?audience [k human])
      (then (bind (speech-worthy ?belief ?audience) ?worthy))
      (else
        (for-each ?part (every {?audience participant ? /pres})
          (bind ?part.target ?participant)
          (if (and (neq ?participant @self) (speech-worthy ?belief ?participant))
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
; about it. A response itself asks for none. The
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

; WHAT A MAN MAKES OF A LINE SAID TO HIM IS ON THAT LINE'S OWN RECORD in the log of the talk it was
; said in (bbk-line, boards/talk.mc), written by him as he hears it (note-reply-state, run by the
; hear func) and tended at the head of each of his deliberations (tend-replies, the engine's /tend):
; reply says he owes it one; waits-on says what it waits on - a then, there, he, she or it its talk
; leaves unsaid, or, for a statement he owes a reply, a man he must first ask which one he is. He
; wonders what was meant by the first such, which has him ask back (tasks/find-out-task.mc); once
; nothing is left unsaid the line is heard again for what waited in it. He replies to a line owed a
; reply that waits on nothing (drivers/respond-driver.mc), the oldest first. Presented, every owed
; line gets its reply; unpresented only a line owed wherever it is said. Nothing else holds any of
; this: that a reply was given is the reply's own record further down the log.

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
; it is said (a question, a flirt), or, presented, owed from a participant of the talk he is in - but not a
; statement that answers what he asked.
(define-func owed-reply (?line)
  (bind ?line.subject ?speaker)
  (bind (line-kind ?line) ?kind)
  (and (neq ?speaker @self)
       (not (and (eq ?kind statement) (is-belief (awaited-inquire ?speaker))))
       (or (has-facet ?kind answer-owed)
           (and (has-facet ?kind answer-owed-in-talk) (presented-lod) (in-one-talk @self ?speaker)))))

; (line-wait ?line ?owed) - what the line ?line said to @self waits on: the first then, there, he,
; she or it its talk leaves unsaid; else ghost, when he owes it a reply (?owed) and it is a
; statement about a man he must first ask which one he is (awaited-ghost) - that man is his own
; notion and no board holds him; else @nothing.
(define-func line-wait (?line ?owed)
  (bind (tolerate (unresolved-in ?line)) ?references)
  (cond (case (and (is-list ?references) (not (empty ?references))) (head ?references))
        (case (and ?owed (eq (line-kind ?line) statement) (is-object (awaited-ghost ?line))) ghost)
        (else @nothing)))

; (note-reply-state ?SAY) - the line ?SAY just said to @self gets, on its record in the talk it was
; said in, what he makes of it: a reply owed, when he holds his part in that talk - a line said to
; a man still only hailed is answered by his taking the hail up or turning it down - and what it
; waits on. @true when it waits on what its speaker meant, so nothing it says is taken in yet.
(define-func note-reply-state (?SAY)
  (bind (said-in ?SAY) ?talk)
  (bind @false ?waits)
  (if (substantial ?talk)
      (then
        (bind (and (holds-part @self ?talk) (eq (tolerate (owed-reply ?SAY)) @true)) ?owed)
        (bind (line-wait ?SAY ?owed) ?wait)
        (if ?owed
            (then (bb-public-write-rec ?talk bbk-line ?SAY (/reply owed))))
        (if (substantial ?wait)
            (then (bb-public-write-rec ?talk bbk-line ?SAY (/waits-on ?wait))))
        (bind (and (substantial ?wait) (neq ?wait ghost)) ?waits)))
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

; (owed-line ?talk) - the oldest line in ?talk's log said to @self by a man still on its board that
; he owes a reply and that waits on nothing, or @nothing: the line he replies to next.
(define-func owed-line (?talk)
  (bind @nothing ?next)
  (for-each ?line (bb-public-read-keys ?talk bbk-line (/reply owed))
    (if (and (eq ?line.auxiliary @self)
             (in-talk ?line.subject ?talk)
             (unsubstantial (bb-public-read-rec ?talk bbk-line ?line waits-on)))
        (then (bind ?line ?next) (break))))
  ?next)

; (line-speaker ?line) - the man who said the line ?line, or @nothing when ?line is none.
(define-func line-speaker (?line)
  (flip (is-belief ?line) ?line.subject @nothing))

; (settle-heard-line ?talk ?line ?was) - the line ?line of ?talk, said to @self and waiting on ?was,
; is tested again: once its talk leaves no reference unsaid it is heard again for what waited in
; it, and its record says what it waits on now, or nothing.
(define-func settle-heard-line (?talk ?line ?was)
  (bind (eq (bb-public-read-rec ?talk bbk-line ?line reply) owed) ?owed)
  (bind (line-wait ?line ?owed) ?wait)
  (if (and (substantial ?was) (neq ?was ghost) (or (unsubstantial ?wait) (eq ?wait ghost)))
      (then
        (rehear-line ?line)
        (bind (line-wait ?line ?owed) ?wait)))
  (if (neq ?wait ?was)
      (then (bb-public-write-rec ?talk bbk-line ?line (/waits-on ?wait)))))

; (settle-line-to-me ?talk ?line) - the line ?line of ?talk, said to @self, is owed and waits for
; nothing more.
(define-func settle-line-to-me (?talk ?line)
  (if (substantial (bb-public-read-rec ?talk bbk-line ?line reply))
      (then (bb-public-write-rec ?talk bbk-line ?line (/reply @nothing))))
  (if (substantial (bb-public-read-rec ?talk bbk-line ?line waits-on))
      (then (bb-public-write-rec ?talk bbk-line ?line (/waits-on @nothing)))))

; (settle-lines-to-me ?talk) - every line of ?talk said to @self is owed and waits for nothing more:
; he is leaving it.
(define-func settle-lines-to-me (?talk)
  (for-each ?line (bb-public-read-keys ?talk bbk-line)
    (if (eq ?line.auxiliary @self)
        (then (settle-line-to-me ?talk ?line)))))

; (meaning-wanted ?talk ?speaker ?reference) - a line ?speaker said to @self in ?talk still waits on
; what he meant by ?reference.
(define-func meaning-wanted (?talk ?speaker ?reference)
  (bind @false ?wanted)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line (/waits-on ?reference))
          (if (and (eq ?line.subject ?speaker) (eq ?line.auxiliary @self))
              (then (bind @true ?wanted) (break))))))
  ?wanted)

; (tend-replies) - at the head of each deliberation: every line of the talk @self is in that was
; said to him and is owed a reply or waits on something is tested again, oldest first; a line whose speaker has left
; the talk is owed and waits for nothing more; a wonder about what a speaker meant ends once no
; line waits on it; and he wonders about the first reference the oldest waiting line leaves
; unsaid, one speaker's at a time.
(define-func /tend tend-replies ()
  (bind (talk-of @self) ?talk)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (eq ?line.auxiliary @self)
              (then
                (bind (bb-public-read-rec ?talk bbk-line ?line waits-on) ?was)
                (bind (eq (bb-public-read-rec ?talk bbk-line ?line reply) owed) ?owed)
                (cond (case (not (in-talk ?line.subject ?talk)) (settle-line-to-me ?talk ?line))
                      (case (or ?owed (substantial ?was)) (settle-heard-line ?talk ?line ?was))))))))
  (for-each ?wonder (every {@self wonder {? means ? ?}})
    (bind ?wonder.target ?meant)
    (if (not (meaning-wanted ?talk ?meant.subject ?meant.target))
        (then (end-belief ?wonder))))
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (bind ?line.subject ?speaker)
          (if (eq ?line.auxiliary @self)
              (then
                (bind (bb-public-read-rec ?talk bbk-line ?line waits-on) ?reference)
                (if (and (substantial ?reference) (neq ?reference ghost)
                         (none {@self wonder {?speaker means ? ?}}))
                    (then (wonder-meaning ?speaker ?reference)))))))))

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
        (for-each ?participant (talk-participants ?talk)
          (if (and (neq ?participant @self)
                   (or (substantial (any {@self inquire|respond ?participant ?}))
                       (substantial (any {@self catch-up|tell-gossip|get-acquainted ?participant}))
                       (wants-to-ask ?participant)
                       (substantial (news-for ?participant))
                       (substantial (gossip-for ?participant))))
              (then (bind @true ?more) (break))))))
  ?more)

; (hailed ?talk) - a participant on ?talk's board is still only hailed there: he has not taken his
; part, so he has not yet shown whether he has anything to say.
(define-func hailed (?talk)
  (bind @false ?hailed)
  (for-each ?participant (talk-participants ?talk)
    (if (eq (standing-in ?talk ?participant) hailed)
        (then (bind @true ?hailed) (break))))
  ?hailed)

; (said-all ?talk) - nobody in ?talk has anything left to say, @self included. A man whose hail
; still stands in it, or who is still only hailed there, has yet to say what he came for.
(define-func said-all (?talk)
  (if (substantial ?talk)
      (then (and (not (agenda-for ?talk))
                 (bb-public-none ?talk has-more)
                 (unsubstantial (bb-public-any ?talk bbk-hail))
                 (not (hailed ?talk))))
      (else @false)))

; (talked-out ?talk ?part) - nobody in ?talk has anything left to say (said-all), and a participant of it
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
    (case (matches ?answer (formulaic ?..)) ?answer)
    (else (answer-as-sure (msg /utterable /reply [] ?answer) ?certainty))))

; (answer-as-sure ?line ?certainty) - ?line as sure as @self is of it: a line he would swear to rides
; nothing, any other how sure he is.
(define-func answer-as-sure (?line ?certainty)
  (if (= ?certainty @true)
      (then ?line)
      (else (set-msg-rider ?line certainty ?certainty))))

; (focus-of ?talk) - whom @self faces in ?talk: the participant he means to say a line to, else the first
; other participant in it.
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
        (for-each ?participant (talk-participants ?talk)
          (if (neq ?participant @self)
              (then (bind ?participant ?focus) (break))))))
  ?focus)

; (can-hail ?thing) - the player can hail ?thing: a living man within (k-hail-reach) of him, as
; the world has it - the player holds no beliefs. The man hailed stays where he stands, so the
; player is the one who walks up. The host shows its Talk hint and lets T hail him on it.
(define-func can-hail (?thing)
  (and (is-a ?thing [k human])
       (neq (attr ?thing condition) [k dead])
       (< (distance (spatial @self bounds /env) (spatial ?thing bounds /env)) (k-hail-reach))))

; (engaged-here ?npc) - the player and ?npc talk together (conversing-with) and the player is still
; within earshot of his speech: the host opens the dialogue on it.
(define-func engaged-here (?npc)
  (and (conversing-with ?npc)
       (in-earshot ?npc [k speech])))

; (player-join ?npc) - the player takes his part in the talk he and ?npc are on the board of once a
; hail between them stands taken up: he has no mind to take it with, so the host asks this of him.
(define-func player-join (?npc)
  (bind (talk-of @self) ?talk)
  (if (and (in-talk ?npc ?talk) (taken-between ?npc) (not (holds-part @self ?talk)))
      (then (bb-public-write-rec ?talk bbk-roster @self (/standing in)))))

; (player-hailer) - the man hailing the player: the one the record of the talk he is in names
; (hailer-in), unless the player is hailing that man himself - the two have then taken each other up;
; or @nothing. The host offers the player to take him up.
(define-func player-hailer ()
  (bind (talk-of @self) ?talk)
  (bind (flip (substantial ?talk) (hailer-in ?talk) @nothing) ?hailer)
  (flip (and (substantial ?hailer) (not (hailing ?hailer))) ?hailer @nothing))

; (player-take-up ?npc) - the player takes up the hail ?npc made to him, as a man's take-up does
; (take-up-into): his answer is on the talk's record of him. The answer is the line the player says back, the response ?npc's opening asks for
; (hail-response) as the reply to it, or @nothing when no opening stands.
(define-func player-take-up (?npc)
  (bind (hail-line ?npc @self) ?opening)
  (if (and (is-belief ?opening) (in-one-talk ?npc @self))
      (then
        (set-hail-state ?npc taken)
        (as-reply-to (hail-response ?opening.target) ?opening))
      (else @nothing)))

; (player-unseat-hailed ?npc) - the player's hail of ?npc is over: ?npc, when he is still only hailed there, comes off
; the board of the talk the player is in, and the player with him when nobody else is on it.
(define-func player-unseat-hailed (?npc)
  (clear-hail ?npc)
  (bind (talk-of @self) ?talk)
  (if (and (substantial ?talk) (eq (standing-in ?talk ?npc) hailed))
      (then
        (bb-public-clear-rec ?talk bbk-roster ?npc)
        (if (not (other-participant-in ?talk))
            (then (bb-public-clear-rec ?talk bbk-roster @self)))
        (let-go-talk ?talk))))

; (player-hail ?npc ?authority) - the player hails ?npc as a man's hail does (tasks/hail-task.mc):
; whoever else he hailed before and was not taken up by comes off his talk's board, and the hail is
; made in a talk from its first instant - ?npc's when he is in one, else the player's own or a
; new one, on whose board the player puts them both - and only ?npc taking it up brings ?npc to
; hold his part in it. A man already hailing the player has his hail taken by it: two who hail each
; other have each taken the other up. The answer is the line he hails him with, its opening -
; plainly, or, when ?authority names the kind of his job, introducing himself by it.
(define-func player-hail (?npc ?authority)
  (bind (talk-of @self) ?standing)
  (if (substantial ?standing)
      (then
        (for-each ?hailed (talk-participants ?standing)
          (if (and (neq ?hailed @self) (neq ?hailed ?npc))
              (then (player-unseat-hailed ?hailed))))))
  (clear-hail ?npc)
  (if (hailed-by ?npc)
      (then (set-hail-state ?npc taken)))
  (if (unsubstantial (talk-of ?npc))
      (then
        (bind (talk-of @self) ?talk)
        (if (unsubstantial ?talk)
            (then
              (bind (open-talk) ?talk)
              (seat ?talk @self)))
        (seat ?talk ?npc)))
  (if (is-kind ?authority)
      (then (formulaic [] opening-phrase authority ?authority))
      (else (formulaic [] opening-phrase player_talk))))

; (owed-question ?participant) - the question @self last put to ?participant, or to the talk they are in now,
; that ?participant has said nothing in reply to: what a line ?participant says to him now answers, or @nothing.
; The host asks it of the man the player speaks to, and the player's line is caused by it.
(define-func owed-question (?participant)
  (bind (shared-talk ?participant) ?talk)
  (bind @nothing ?owed)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject @self)
                   (or (eq ?line.auxiliary ?participant) (eq ?line.auxiliary ?talk))
                   (matches ?line.target (qs ?..))
                   (not (replied ?participant ?line)))
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
; the line he takes his leave with. He comes off its board and his hail of ?npc ends.
(define-func player-leave-taking (?npc)
  (player-unseat-hailed ?npc)
  (bind (talk-of @self) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-clear-rec ?talk bbk-roster @self)
        (let-go-talk ?talk)))
  (formulaic [] leave-taking player_bye))
