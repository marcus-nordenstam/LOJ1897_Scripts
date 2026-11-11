; ----------------------------------------------------------------------------
; conversation.mc - who hears whom, how a man answers being hailed, and how a conversation
; he opened goes.
;
; Speech has one task that proposes SAY: tell (tasks/tell-task.mc) says one thing where its
; audience can hear it. A man is in a conversation while he holds {<talk> participant @self}:
; hail or take-up begins it, and leaving ends it (drivers/stay-in-conversation-driver.mc).
; Everything he says in it, and every way he leaves it, keys off that part;
; maintain-social-presence only keeps his body with the others.
;
; A CONVERSATION is ONE object, shared (share-object): the opener invents it, and every party
; holds his own copy of it, linked to the one the world keeps. Its public board is what keeps the
; group in step: its participant set is who takes part (parties-of) and its has-more set who still
; has something to say. Joining adds him to the set and leaving takes him off it; a change to
; either set wakes every party reading it, busy or not, and each mirrors it in his own mind
; (conversation-roster-join / -leave). When the last party leaves, the board is empty and the
; world lets the conversation go. What a man knows of a talk
; is his own beliefs, kept to the board: {<talk> participant <party>} for each party, one
; interval per spell (conversation-roster-join / -leave), {<talk> venue <space>} while he is in
; it, {<talk> occasion <occasion>} when it is part of one.
;
; A HAIL is a (formulaic opening-phrase ..) said to @self by a man in a conversation @self is not
; in. It is always answered, and how is his choice: he takes up the
; conversation, declines it for what he is busy with, or rebuffs a man he despises
; (drivers/answer-hail-driver.mc).
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
; a conversation when every party @self knows to be in it is. tell closes on its audience until
; this holds.
(define-func within-voice (?listener ?msg)
  (if (and (is-object ?listener) (is-a ?listener [k conversation]))
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

; (taking-up ?caller) - @self has begun taking up ?caller's conversation.
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

; (conversation-of ?party) - the conversation whose participant set holds ?party, or @nothing. A
; man takes part in one conversation at a time.
(define-func conversation-of (?party)
  (bind @nothing ?talk)
  (for-each ?one (bb-public-every ? participant ?party)
    (bind ?one ?talk)
    (break))
  ?talk)

; (in-conversation ?party ?talk) - ?talk's participant set holds ?party.
(define-func in-conversation (?party ?talk)
  (and (substantial ?talk) (substantial (bb-public-any ?talk participant ?party))))

; (in-one-conversation ?party ?partner) - both take part in one conversation: a talk they share,
; not yet a talk between them (conversing-with).
(define-func in-one-conversation (?party ?partner)
  (in-conversation ?partner (conversation-of ?party)))

; A LINE TAKES A TURN: one man at a time speaks on a board, the rest wait for it, and the man who
; is done hands it on (turn-request, holds-turn, turn-release - the engine's). A line to a
; conversation, or to a man in one, takes that conversation's turn; a line to a man in no
; conversation takes his own; a broadcast takes none. A line answering one said to the speaker
; goes before the rest, and of the others the man longest since he last spoke. A man being called
; (another holds his own turn) answers before he calls anyone, so two men never call each other
; at once; and a man spoken to stays where he is (heed-speaker).

; (turn-board ?audience) - the board whose turn a line to ?audience takes, or @nothing.
(define-func turn-board (?audience)
  (cond (case (unsubstantial ?audience) @nothing)
        (case (is-a ?audience [k conversation]) ?audience)
        (case (in-one-conversation @self ?audience) (conversation-of @self))
        (case (substantial (conversation-of ?audience)) (conversation-of ?audience))
        (else ?audience)))

; (answering-line ?msg ?audience) - the line @self is telling ?audience answers one ?audience said
; to him: his tell of it was caused by that line.
(define-func answering-line (?msg ?audience)
  (bind @false ?answers)
  (for-each ?tell (every {@self tell ?msg ?audience /pres})
    (if (substantial (tolerate (caused-by ?tell {?audience SAY ? @self /ever})))
        (then (bind @true ?answers) (break))))
  ?answers)

; (line-rank ?msg ?audience) - how soon a line waits its turn: an answer goes first.
(define-func line-rank (?msg ?audience)
  (flip (answering-line ?msg ?audience) 1 0))

; (my-turn ?audience) - @self may speak to ?audience now: the line takes no turn, or he holds it.
(define-func my-turn (?audience)
  (bind (turn-board ?audience) ?board)
  (or (unsubstantial ?board) (holds-turn ?board)))

; (line-took-its-turn ?SAY ?audience) - the line ?SAY @self began saying to ?audience had its turn:
; the tell that proposed it answers him, or @self holds the turn it takes.
(define-func line-took-its-turn (?SAY ?audience)
  (bind (caused-by ?SAY {@self tell ? ?audience}) ?tell)
  (or (and (is-belief ?tell) (answering-line ?tell.target ?audience)) (my-turn ?audience)))

; (may-speak?msg ?audience) - @self may say ?msg to ?audience now: an answer to him takes no turn,
; since he asked for it; any other line waits for its turn and for no one to be calling @self.
(define-func may-speak (?msg ?audience)
  (or (answering-line ?msg ?audience)
      (and (my-turn ?audience) (not (being-called)))))

; (being-called) - another man holds @self's own turn: he is calling @self.
(define-func being-called ()
  (turn-held-by-another @self))

; (spoken-to) - another man holds the turn of @self, or of the conversation he is in.
(define-func spoken-to ()
  (bind (conversation-of @self) ?talk)
  (or (turn-held-by-another @self)
      (and (substantial ?talk) (turn-held-by-another ?talk))))

; (speaking) - a line of @self's is being said: his SAY runs, and it holds his turn until it ends
; however it ends, whatever stopped the tell that proposed it (thinks/give-up-turns-think.mc).
(define-func speaking ()
  (substantial (any {@self SAY ?})))

; (release-line-turns ?ended-tell) - the tell ?ended-tell is over: the turn its line took gives way
; unless another tell of @self's takes it too, and when no other tell of his runs, every turn he
; holds or waits for does.
(define-func release-line-turns (?ended-tell)
  (bind (turn-board ?ended-tell.auxiliary) ?board)
  (bind @false ?other)
  (bind @false ?shared)
  (for-each ?tell (every {@self tell ? ?})
    (if (neq ?tell ?ended-tell)
        (then
          (bind @true ?other)
          (bind (turn-board ?tell.auxiliary) ?theirs)
          (if (and (substantial ?theirs) (substantial ?board))
              (then (if (eq ?theirs ?board) (then (bind @true ?shared))))))))
  (cond (case (not ?other) (turn-release ?))
        (case (and (substantial ?board) (not ?shared)) (turn-release ?board))))

; (conversing-with ?partner) - @self and ?partner talk together: both are in one conversation, and
; since @self joined it a hail between them has been answered - his hail taken up, or ?partner's
; taken up by him. Being in one talk with a man is not yet talking to him.
(define-func conversing-with (?partner)
  (bind (conversation-of @self) ?talk)
  (bind (any {?talk participant @self}) ?part)
  (and (is-belief ?part)
       (in-conversation ?partner ?talk)
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
  (bind (conversation-of ?partner) ?theirs)
  (if (and (substantial ?theirs) (not (in-conversation @self ?theirs)))
      (then (bind (+ /float (count (parties-of ?theirs)) -1) ?claims)))
  ?claims)

; (turned-down-by ?other) - the last thing ?other said to @self turned a hail of his down.
(define-func turned-down-by (?other)
  (bind (any {?other SAY ? @self /past /most_recent}) ?said)
  (and (is-belief ?said) (matches ?said.target (formulaic ? refusal|rebuff ?..))))

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

; (invited-by ?caller) - the hail ?caller called to @self stands: his hailing set holds @self.
; Whether it is answered is the reader's role: no take-up or turn-down of @self's caused by it has
; succeeded.
(define-func invited-by (?caller)
  (substantial (bb-public-any ?caller hailing @self)))

; (hail-accepted ?partner ?hail) - ?partner answered the opening @self called in ?hail without
; turning it down, and the two are in one conversation.
(define-func hail-accepted (?partner ?hail)
  (bind (hail-opening ?partner ?hail) ?said)
  (and (is-belief ?said)
       (substantial (any {?partner SAY ? @self /succ /caused_by ?said}))
       (none {?partner SAY (formulaic ? refusal|rebuff ?..) @self /succ /caused_by ?said})
       (in-one-conversation ?partner @self)))

; (hail-turned-down ?partner ?hail) - ?partner answered the opening @self called in ?hail with a
; refusal or a rebuff.
(define-func hail-turned-down (?partner ?hail)
  (bind (hail-opening ?partner ?hail) ?said)
  (and (is-belief ?said)
       (substantial (any {?partner SAY (formulaic ? refusal|rebuff ?..) @self /succ /caused_by ?said}))))

; (join-conversation ?talk ?act) - @self takes part in ?talk: he joins its participant set, and he knows
; himself a party of it, caused by ?act that joins him, where it is held when he did not yet, and the
; occasion it is part of when he holds one for here today. Joining the talk he is in already changes
; nothing.
(define-func join-conversation (?talk ?act)
  (bb-public-add-member ?talk participant @self)
  (if (unsubstantial (any {?talk participant @self}))
      (then (begin-belief {?talk participant @self /caused_by ?act})))
  (if (unsubstantial (any {?talk venue ?}))
      (then (begin-belief {?talk venue (spatial @self space)})))
  (bind (o /known [k occasion] {@o venue (spatial @self building)} {@o held-on (time date)}) ?occasion)
  (if (and (substantial ?occasion) (unsubstantial (any {?talk occasion ?})))
      (then (begin-belief {?talk occasion ?occasion}))))

; (open-conversation) - a new conversation, a shared object, for @self to join. Taking up a hail
; makes one when neither man is in a conversation.
(define-func open-conversation ()
  (share-object (o /invent [k conversation])): ?talk
  ?talk)

; (parties-of ?talk) - every party in ?talk: its participant set.
(define-func parties-of (?talk)
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
  (for-each ?party (parties-of ?talk)
    (if (neq ?party @self)
        (then (bind @true ?still) (break))))
  ?still)

; (roster-lacks ?talk) - a party in ?talk is not yet a participant of it in @self's mind.
(define-func roster-lacks (?talk)
  (bind @false ?lacks)
  (for-each ?party (parties-of ?talk)
    (if (unsubstantial (any {?talk participant ?party}))
        (then (bind @true ?lacks) (break))))
  ?lacks)

; (roster-add ?talk) - every party in ?talk takes part in it from now in @self's mind.
(define-func roster-add (?talk)
  (for-each ?party (parties-of ?talk)
    (if (unsubstantial (any {?talk participant ?party}))
        (then (begin-belief {?talk participant ?party})))))

; (conversation-full ?talk) - ?talk seats no one more (conversation-size-max).
(define-func conversation-full (?talk)
  (>= (count (parties-of ?talk)) (conversation-size-max)))

; (hailable ?partner) - @self may hail ?partner, THE gate on every hail: he is awake to hear it, his
; last word to @self did not turn him down - that man seeks @self out himself - he is in no
; conversation, or in one that seats another, and @self is in none that seats no one more, since
; ?partner taking him up would join it.
(define-func hailable (?partner)
  (bind (conversation-of ?partner) ?theirs)
  (and (not (attr-is ?partner awareness [k asleep]))
       (not (attr-is ?partner awareness [k unconscious]))
       (not (turned-down-by ?partner))
       (or (unsubstantial ?theirs) (not (conversation-full ?theirs)))
       (not (in-full-talk))))

; (in-full-talk) - @self is in a conversation that seats no one more.
(define-func in-full-talk ()
  (bind (conversation-of @self) ?talk)
  (and (substantial ?talk) (conversation-full ?talk)))

; (talk-between ?partner) - the conversation @self and ?partner would talk in: ?partner's when he is
; in one with room, else @self's own with room, else @nothing - a new one. It is what every act of
; talking with ?partner happens within (scope), so a talk of his hosts it only when it is that one.
; While ?partner's seats no one more they cannot talk at all, and the act moves @self nowhere: it is
; within his own talk, where it waits or fails (hailable).
(define-func talk-between (?partner)
  (bind (conversation-of ?partner) ?theirs)
  (bind (conversation-of @self) ?mine)
  (cond (case (and (substantial ?theirs) (conversation-full ?theirs)) ?mine)
        (case (substantial ?theirs) ?theirs)
        (case (and (substantial ?mine) (not (conversation-full ?mine))) ?mine)
        (else @nothing)))

; (take-up-talk ?partner) - the conversation @self takes ?partner's hail up into: the one they would
; talk in (talk-between), a new one when that is none; @fail when ?partner's seats no one more.
(define-func take-up-talk (?partner)
  (bind (conversation-of ?partner) ?theirs)
  (bind (talk-between ?partner) ?talk)
  (cond (case (and (substantial ?theirs) (conversation-full ?theirs)) @fail)
        (case (eq ?talk @nothing) (open-conversation))
        (else ?talk)))

; (leave-conversation ?talk) - @self leaves the conversation ?talk: he comes off its participant
; and has-more sets, and his part in it and his knowing where it is held end.
(define-func leave-conversation (?talk)
  (if (substantial ?talk)
      (then
        (if (not (speaking))
            (then (turn-release ?talk)))
        (bb-public-remove-member ?talk participant @self)
        (bb-public-remove-member ?talk has-more @self)
        (end-belief {?talk participant @self})
        (end-belief {?talk venue ?}))))

; (has-more-anywhere ?party) - a conversation's has-more set still holds ?party.
(define-func has-more-anywhere (?party)
  (bind @false ?more)
  (for-each ?one (bb-public-every ? has-more ?party)
    (bind @true ?more)
    (break))
  ?more)

; A conversation lasts until its parties have run out of things to say. What a man still has to
; say in one is his AGENDA, never stored: what his mind yields for it now (agenda-for). While it is
; not empty he shows it - he is in the conversation's has-more set - and comes off it when it is
; (thinks/conversation-has-more-think.mc).
; He is done with a conversation when his agenda is empty and its has-more set is (said-all): the
; last to run out takes his leave, and his goodbye wakes the rest.

; (asked-news ?friend ?talk) - @self has asked ?friend what is new since he joined ?talk.
(define-func asked-news (?friend ?talk)
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?asked)
  (if (substantial ?part)
      (then
        (for-each ?SAY (every {@self SAY (qs ? (news-for ?..)) ?friend /succ})
          (if (happened-since ?SAY ?part)
              (then (bind @true ?asked) (break))))))
  ?asked)

; (replied ?speaker ?said) - ?speaker has said something to @self in reply to @self's line ?said: a
; line of his caused by it.
(define-func replied (?speaker ?said)
  (substantial (any {?speaker SAY ? @self /succ /caused_by ?said})))

; (hail-opening ?partner ?hail) - the opening @self called to ?partner in ?hail, or @nothing.
(define-func hail-opening (?partner ?hail)
  (any {@self SAY (formulaic ? opening-phrase ?..) ?partner /succ /caused_by ?hail}))

; (hail-reply ?partner ?hail) - what ?partner said in reply to the opening @self called in ?hail,
; or @fail.
(define-func hail-reply (?partner ?hail)
  (bind (hail-opening ?partner ?hail) ?said)
  (if (is-belief ?said)
      (then (any {?partner SAY ? @self /succ /caused_by ?said}))
      (else @fail)))

; (inquiry-of ?fact) - the question that searches the fact clause ?fact.
(define-func inquiry-of (?fact)
  (qs /utterable [/msg-class inquiry] (any ?fact)))

; (askable ?who ?fact) - @self may ask ?who for the fact clause ?fact: he could know it, @self does
; not take him not to know it, and he has not refused to tell @self it.
(define-func askable (?who ?fact)
  (and (could-know ?who ?fact) (none {?who /not know ?fact}) (none {?who withhold ?fact @self})))

; (wants-to-ask ?party) - @self wonders about something ?party could tell him.
(define-func wants-to-ask (?party)
  (bind @false ?asks)
  (for-each ?wonder (every {@self wonder ?})
    (if (askable ?party ?wonder.target)
        (then (bind @true ?asks) (break))))
  ?asks)

; (said-to ?lines ?listener) - one of @self's lines ?lines reached ?listener: said to his face, or to
; a talk he took part in.
(define-func said-to (?lines ?listener)
  (bind @false ?said)
  (for-each ?SAY ?lines
    (bind ?SAY.auxiliary ?audience)
    (if (and (is-object ?audience)
             (or (eq ?audience ?listener)
                 (substantial (any {?audience participant ?listener /ever}))))
        (then (bind @true ?said) (break))))
  ?said)

; (told-to ?belief ?listener) - @self has said ?belief to ?listener, alone or in a bundled line.
(define-func told-to (?belief ?listener)
  (or (said-to (every {@self SAY (msg ? ?belief) ? /succ /ever}) ?listener)
      (said-to (every {@self SAY (msg ? ~[?belief]) ? /succ /ever}) ?listener)))

; (speakable ?belief) - ?belief is a thing @self can say: a belief he holds, not forgotten, and still
; true now. Whatever is picked to be told - news, gossip, an aspect of himself - is speakable.
(define-func speakable (?belief)
  (and (is-belief ?belief) (eq (end-time ?belief) @ongoing)))

; (speech-worthy ?belief ?friend) - @self may tell ?friend the belief ?belief: it is speakable,
; ?friend is no party of it, its tier admits him, and either @self takes him not to know it or has
; not told it to him.
(define-func speech-worthy (?belief ?friend)
  (and (speakable ?belief)
       (not (involved-in ?friend ?belief))
       (disclosable-to ?belief ?friend)
       (or (substantial (any {?friend /not know (clausify ?belief)}))
           (not (told-to ?belief ?friend)))))

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
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?answered)
  (if (substantial ?part)
      (then
        (for-each ?SAY (every {@self SAY (qs ? (news-for ?..)) ?friend /succ})
          (if (and (happened-since ?SAY ?part) (replied ?friend ?SAY))
              (then (bind @true ?answered) (break))))))
  ?answered)

; (caught-up ?friend) - in a talk with ?friend, @self has told him all his news and has asked his.
(define-func caught-up (?friend)
  (bind (conversation-of @self) ?talk)
  (and (substantial ?talk)
       (unsubstantial (news-for ?friend))
       (asked-and-answered ?friend ?talk)))

; (remarked-in ?talk) - @self has made his smalltalk remark in ?talk: one a talk.
(define-func remarked-in (?talk)
  (bind @false ?remarked)
  (for-each ?smalltalk (every {@self smalltalk ? ?talk /ever})
    (if (substantial (any {@self tell (msg ~[/msg-class smalltalk] ?..) ? /succ /caused_by ?smalltalk}))
        (then (bind @true ?remarked) (break))))
  ?remarked)

; Every line said to a man makes a response from him relevant, and its kind decides which: a
; question an answer, an opening an opening's answer, a flirt a flirt's answer, a remark a remark
; or agreement, tidings tidings of his own or a receipt. A response itself calls for none. The
; respond driver (drivers/respond-driver.mc) owes it, the respond task says it, caused by the line.

; (line-kind ?msg) - the kind of move ?msg is: inquiry (a question), opening-phrase (a hail),
; flirtation (a flirt), smalltalk (a remark), tidings (news), or reply - anything that answers a
; line rather than calling for an answer, an unclassified line among them.
(define-func line-kind (?msg)
  (cond (case (matches ?msg (qs ?..)) inquiry)
        (case (matches ?msg (formulaic ? opening-phrase ?..)) opening-phrase)
        (case (matches ?msg (formulaic ? flirt compliment ?..)) flirtation)
        (case (matches ?msg (msg ~[/msg-class smalltalk] ?..)) smalltalk)
        (case (matches ?msg (msg ~[/msg-class tidings] ~[?])) reply)
        (case (matches ?msg (msg ~[/msg-class tidings] ?..)) tidings)
        (else reply)))

; (owes-response ?msg) - a line ?msg said to @self calls for a response from him.
(define-func owes-response (?msg)
  (neq (line-kind ?msg) reply))

; (reply-to ?msg ?speaker) - the response @self gives ?speaker's line ?msg, or @nothing.
(define-func reply-to (?msg ?speaker)
  (switch (line-kind ?msg)
    (on inquiry (answer-to ?msg ?speaker))
    (on opening-phrase (opening-reply ?msg ?speaker))
    (on flirtation (flirt-reply ?speaker))
    (on smalltalk (smalltalk-reply (conversation-of @self)))
    (on tidings (tidings-reply ?speaker))
    (else @nothing)))

; (opening-reply ?opening ?speaker) - what @self answers an opening ?speaker said to him in a
; conversation he is in: a rebuff when he despises him, else the response the opening calls for.
; A man already talking is never too busy for one joining his talk, so only a rebuff turns him away.
(define-func opening-reply (?opening ?speaker)
  (if (rebuffs ?speaker)
      (then (formulaic [/msg-class insult] rebuff))
      (else (hail-response ?opening))))

; (tidings-reply ?speaker) - what @self answers ?speaker's tidings with: tidings of his own the
; friend has not heard, else the receipt of them.
(define-func tidings-reply (?speaker)
  (bind @nothing ?news)
  (if (substantial (any {@self (closeness-labels friend) ?speaker}))
      (then (bind (news-for ?speaker) ?news)))
  (if (substantial ?news)
      (then (msg /utterable [/msg-class tidings] ?news))
      (else (formulaic [/msg-class reply] response receipt))))

; (smalltalk-reply ?talk) - what @self answers a remark with in ?talk: his own remark, building on
; it, or having none, agreement.
(define-func smalltalk-reply (?talk)
  (bind (smalltalk-line ?talk) ?remark)
  (if (substantial ?remark)
      (then ?remark)
      (else (formulaic [/msg-class smalltalk] response agree))))

; (awaits-smalltalk-answer ?talk ?partner) - the last smalltalk remark ?partner made to @self, in
; ?talk, is still unanswered.
(define-func awaits-smalltalk-answer (?talk ?partner)
  (bind (any {?talk participant @self}) ?part)
  (bind (any {?partner SAY (msg ~[/msg-class smalltalk] ?..) @self /past /most_recent}) ?line)
  (if (substantial ?line)
      (then (and (happened-since ?line ?part) (none {@self tell ? ?partner /succ /caused_by ?line})))
      (else @false)))

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
              (then (bind (msg /utterable [/msg-class smalltalk] ?weather) ?line) (break))))))
  ?line)

; (flirted-in ?talk) - @self has made his flirt in ?talk: one a talk.
(define-func flirted-in (?talk)
  (bind @false ?flirted)
  (for-each ?flirt (every {@self flirt ? ?talk /ever})
    (if (substantial (any {@self tell (formulaic ~[/msg-class flirtation] flirt compliment) ? /succ /caused_by ?flirt}))
        (then (bind @true ?flirted) (break))))
  ?flirted)

; (awaits-flirt-answer ?talk ?partner) - the last flirt ?partner made to @self, in ?talk, is still
; unanswered.
(define-func awaits-flirt-answer (?talk ?partner)
  (bind (any {?talk participant @self}) ?part)
  (bind (any {?partner SAY (formulaic ~[/msg-class flirtation] flirt compliment) @self /past /most_recent}) ?line)
  (if (substantial ?line)
      (then (and (happened-since ?line ?part) (none {@self tell ? ?partner /succ /caused_by ?line})))
      (else @false)))

; (flirt-reply ?partner) - what @self answers a flirt of ?partner's with, his motives choosing: a flirt
; back to one he fancies, a rebuff - heard as the slight it is - to one he dislikes, else flattered.
(define-func flirt-reply (?partner)
  (if (substantial (any {@self fancy|desire|crave ?partner}))
      (then (formulaic [/msg-class flirtation] flirt return))
      (else
        (if (substantial (any {@self dislike|detest ?partner}))
            (then (formulaic [/msg-class insult] refusal flirt))
            (else (formulaic [/msg-class flirtation] response flattered))))))

; (agenda-for ?talk) - @self still has something to say in ?talk: a dialogue task of his still runs
; there, or a dialogue-line of some class is waiting for someone in it - the union over the classes.
(define-func agenda-for (?talk)
  (bind (or (substantial (any {@self smalltalk|flirt ? ?talk}))
            (and (substantial (any {@self unease ?talk})) (substantial (smalltalk-line ?talk))))
        ?more)
  (if (not ?more)
      (then
        (for-each ?party (parties-of ?talk)
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
        (for-each ?party (parties-of ?talk)
          (if (neq ?party @self)
              (then
                (bind (any {?party SAY ? @self /past /most_recent}) ?said)
                (if (and (is-belief ?said) (happened-since ?said ?part))
                    (then (bind @true ?heard) (break))))))))
  ?heard)

; (answer-to ?qs ?partner) - what @self says to ?partner's question ?qs: its content evaluated in
; his mind, or "nothing much" when it asked his news and he has none.
(define-func answer-to (?qs ?partner)
  (bind (eval-msg /output_unknown_on_fail ?qs ?partner) ?answer)
  (if (and (matches ?qs (qs ? (news-for ?..))) (unsubstantial ?answer))
      (then (formulaic [/msg-class reply] response no-news))
      (else (msg /utterable [/msg-class reply] ?answer))))

; (focus-of ?talk) - whom @self faces in ?talk: the party he is telling a line to, else the first
; other party in it.
(define-func focus-of (?talk)
  (bind @nothing ?focus)
  (bind (any {@self tell ? ?}) ?telling)
  (if (is-belief ?telling)
      (then
        (bind ?telling.auxiliary ?audience)
        (if (and (is-object ?audience) (in-conversation ?audience ?talk))
            (then (bind ?audience ?focus)))))
  (if (unsubstantial ?focus)
      (then
        (for-each ?party (parties-of ?talk)
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

; (engaged-here ?npc) - ?npc has taken up the player's hail and the player is still within
; earshot of his speaking voice: the host opens the dialogue on it.
(define-func engaged-here (?npc)
  (and (in-one-conversation ?npc @self) (in-earshot ?npc [k speech])))

; (player-hail ?npc ?authority) - the player hails ?npc as a man's hail does (tasks/hail-task.mc):
; his one standing hail is to ?npc (hailing), and only ?npc taking it up brings them into a
; conversation. The answer is the line he hails him with - plainly, or, when ?authority names the
; kind of his job, introducing himself by it.
(define-func player-hail (?npc ?authority)
  (for-each ?hailed (bb-public-members @self hailing)
    (bb-public-remove-member @self hailing ?hailed))
  (bb-public-add-member @self hailing ?npc)
  (if (is-kind ?authority)
      (then (formulaic [] opening-phrase authority ?authority))
      (else (formulaic [] opening-phrase player_talk))))

; (player-leave-taking ?npc) - the player leaves the conversation with ?npc, and the answer is
; the line he takes his leave with. He comes off its participant set, and his hail of ?npc ends.
(define-func player-leave-taking (?npc)
  (bb-public-remove-member @self hailing ?npc)
  (bind (conversation-of @self) ?talk)
  (if (substantial ?talk)
      (then (bb-public-remove-member ?talk participant @self)))
  (formulaic [] leave_taking player_bye))
