; ----------------------------------------------------------------------------
; conversation.mc - who hears whom, how a man answers being hailed, and how a conversation
; he opened goes.
;
; Speech has one task that proposes SAY: tell (tasks/tell-task.mc) says one thing where its
; audience can hear it. A conversation is four tasks, each saying its lines through tell: hail
; opens it, take-up accepts it, converse holds the exchange while it is open, and take-leave
; ends it.
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
      (then
        (bind @true ?all-hear)
        (for-each ?party (every {?listener participant ?})
          (bind ?party.target ?who)
          (if (and (neq ?who @self) (not (in-earshot ?who (voice-sound ?msg))))
              (then (bind @false ?all-hear))))
        ?all-hear)
      (else (in-earshot ?listener (voice-sound ?msg)))))

; (answers-to ?speaker) - @self is bound to heed ?speaker's hail: his master, his mother or
; his father.
(define-func answers-to (?speaker)
  (or (any {@self master ?speaker}) (any {@self mother ?speaker}) (any {@self father ?speaker})))

; (law-officer ?x) - @self believes ?x holds a job of a law officer's kind.
(define-func law-officer (?x)
  (substantial (any {?x job [k law-officer]})))

; (evading-law) - @self has the law to fear: he remembers a crime of his own.
(define-func evading-law ()
  (substantial (any {@self kill|shoot|strangle|hurt|steal|coerce|bribe ? /succ /past})))

; (hail-worth ?speaker) - what taking up ?speaker's hail is worth to @self, as a packed
; utility: an obligation when it is a law officer's and he has nothing to hide, or when he
; answers to ?speaker, else a want that rises with how close they are.
(define-func hail-worth (?speaker)
  (cond (case (and (law-officer ?speaker) (not (evading-law)))
              (utility obligation (k-hail-authority-value)))
        (case (answers-to ?speaker) (utility obligation (k-hail-bond-value)))
        (case {@self spouse|lover|friend|close-to|mother|father|child|sibling ?speaker}
              (utility want (k-hail-bond-value)))
        (case {@self acquaintance ?speaker} (utility want (k-hail-acquaintance-value)))
        (else (utility want (k-hail-stranger-value)))))

; (authority-introduction ?msg) - ?msg hails its hearer by introducing the speaker's office:
; (formulaic [] opening-phrase authority <job kind>). Each field is read only once the one
; before has shown the message is long enough to hold it.
(define-func authority-introduction (?msg)
  (if (eq-func-name ?msg formulaic)
      (then (if (eq (nth (k-formulaic-category-field) ?msg) opening-phrase)
                (then (eq (nth (k-formulaic-key-field) ?msg) authority))
                (else @false)))
      (else @false)))

; (hail-response ?opening) - the response a hail's opening calls for: a man who introduced
; himself by his office is answered by it, any other opening by its own key.
(define-func hail-response (?opening)
  (bind (nth (k-formulaic-key-field) ?opening) ?key)
  (if (authority-introduction ?opening)
      (then
        (bind (nth (k-formulaic-office-field) ?opening) ?office)
        (formulaic [] response authority ?office))
      (else (formulaic [] response ?key))))

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
  (bind @nothing ?found)
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

; (conversing-with ?party ?partner) - both take part in one conversation.
(define-func conversing-with (?party ?partner)
  (in-conversation ?partner (conversation-of ?party)))

; A man being spoken to carries the speaker's mark on his public board (addressed) from the moment
; the speaker takes him on until the line is said, and a line said to a conversation marks the
; conversation. A line said outside a conversation (a hail, its answer) marks the speaker's own
; board too, so two men never call to each other at once: the claim decides, and the loser is the
; one called to. tell claims
; the marks (claim-addressees) before it closes on its listener and clears them however it ends
; (release-addressees); a man under another's mark stays where he is (heed-speaker). SAY asserts it
; holds the mark (holds-address).
;
; Inside a conversation one man has the floor at a time (floor, on the conversation's board). Only
; a man with a line waiting bids for it (bidding); of the bidders the one who has waited longest
; since he last spoke takes it (spoke-at, on each man's own board: when his last line ended, unset
; when he has never spoken), and a line answering one said to him (answering) goes before the
; rest. The floor clears when the line is said or given up (release-floor).

; (addressed-by-another ?x) - a man other than @self is speaking to ?x now.
(define-func addressed-by-another (?x)
  (if (substantial ?x)
      (then (and (not (bb-public-none ?x addressed))
                 (unsubstantial (bb-public-any ?x addressed @self))))
      (else @false)))

; (party-addressed ?talk) - a party of ?talk besides @self is being spoken to by another.
(define-func party-addressed (?talk)
  (bind @false ?addressed)
  (for-each ?party (parties-of ?talk)
    (if (and (neq ?party @self) (addressed-by-another ?party))
        (then (bind @true ?addressed) (break))))
  ?addressed)

; (free-to-address ?audience) - nobody else is speaking to anyone @self would speak to: a man and
; the talk he is in, or a talk and every party of it. A broadcast addresses nobody.
(define-func free-to-address (?audience)
  (cond
    (case (unsubstantial ?audience) @true)
    (case (is-a ?audience [k conversation])
          (and (not (addressed-by-another ?audience)) (not (party-addressed ?audience))))
    (else (and (not (addressed-by-another ?audience))
               (not (addressed-by-another (conversation-of ?audience)))))))

; (holds-address ?audience) - @self may say a line to ?audience: it is a broadcast, or his mark
; is on it.
(define-func holds-address (?audience)
  (if (substantial ?audience)
      (then (substantial (bb-public-any ?audience addressed @self)))
      (else @true)))

; (claim-addressees ?audience) - @self marks ?audience as spoken to, and outside a conversation
; himself as speaking, @true, or leaves both as they were, @false, when another man is speaking to
; it, to anyone it reaches, or calling to @self. Marks already his stand.
(define-func claim-addressees (?audience)
  (bind @true ?claimed)
  (if (and (substantial ?audience) (not (holds-address ?audience)))
      (then
        (bind (and (or (in-talk-line ?audience)
                       (substantial (bb-public-any @self addressed @self))
                       (and (bb-public-none @self addressed)
                            (substantial (bb-public-try-write-new @self addressed @self))))
                   (substantial (bb-public-try-write-new ?audience addressed @self))
                   (free-to-address ?audience))
              ?claimed)
        (if (not ?claimed)
            (then (release-addressees ?audience)))))
  ?claimed)

; (floor-talk ?audience) - the conversation whose floor a line to ?audience takes: ?audience itself,
; the one @self is in with him, or, said from outside, the one ?audience is in - a hail to a man in
; a talk waits its turn among the talk's own lines; @nothing when ?audience is in none.
(define-func floor-talk (?audience)
  (cond (case (unsubstantial ?audience) @nothing)
        (case (is-a ?audience [k conversation]) ?audience)
        (case (conversing-with @self ?audience) (conversation-of @self))
        (else (conversation-of ?audience))))

; (in-talk-line ?audience) - a line to ?audience is said inside a conversation @self is in.
(define-func in-talk-line (?audience)
  (or (is-a ?audience [k conversation]) (conversing-with @self ?audience)))

; (holds-floor ?talk) - @self has ?talk's floor.
(define-func holds-floor (?talk)
  (substantial (bb-public-any ?talk floor @self)))

; (waited-longer ?other) - ?other has waited longer to speak than @self: he has never spoken while
; @self has, or his last line ended before @self's did.
(define-func waited-longer (?other)
  (bind (bb-public-read @self spoke-at) ?mine)
  (bind (bb-public-read ?other spoke-at) ?theirs)
  (cond (case (unsubstantial ?mine) @false)
        (case (unsubstantial ?theirs) @true)
        (else (< ?theirs ?mine))))

; (outbid ?talk ?answering) - another bidder for ?talk's floor goes before @self: he answers a line
; when @self does not, or bids as @self does and has waited longer.
(define-func outbid (?talk ?answering)
  (bind @false ?outbid)
  (for-each ?bidder (bb-public-members ?talk bidding)
    (bind (substantial (bb-public-any ?talk answering ?bidder)) ?theirs-answers)
    (if (and (neq ?bidder @self)
             (or (and ?theirs-answers (not ?answering))
                 (and (eq ?theirs-answers ?answering) (waited-longer ?bidder))))
        (then (bind @true ?outbid) (break))))
  ?outbid)

; (answering-line ?msg ?audience) - the line @self is telling ?audience answers one ?audience said
; to him: his tell of it was caused by that line.
(define-func answering-line (?msg ?audience)
  (bind @false ?answers)
  (for-each ?tell (every {@self tell ?msg ?audience /pres})
    (if (substantial (tolerate (caused-by ?tell {?audience SAY ? @self})))
        (then (bind @true ?answers) (break))))
  ?answers)

; (bid-floor ?msg ?audience) - @self bids for the floor of the conversation he says ?msg in, and
; as one answering a line said to him when ?msg does.
(define-func bid-floor (?msg ?audience)
  (bind (floor-talk ?audience) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-add-member ?talk bidding @self)
        (if (answering-line ?msg ?audience)
            (then (bb-public-add-member ?talk answering @self))))))

; (my-turn ?msg ?audience) - @self may say ?msg to ?audience now: it takes no conversation's floor
; (floor-talk), or he has the floor, or the floor is free and no bidder goes before him.
(define-func my-turn (?msg ?audience)
  (bind (floor-talk ?audience) ?talk)
  (cond (case (unsubstantial ?talk) @true)
        (case (holds-floor ?talk) @true)
        (else (and (bb-public-none ?talk floor)
                   (not (outbid ?talk (answering-line ?msg ?audience)))))))

; (take-floor ?audience) - @self takes the floor a line to ?audience takes (floor-talk), @true, or
; loses it to another's claim, @false; a line to a man in no talk takes none.
(define-func take-floor (?audience)
  (bind (floor-talk ?audience) ?talk)
  (or (unsubstantial ?talk)
      (holds-floor ?talk)
      (substantial (bb-public-try-write-new ?talk floor @self))))

; (release-floor) - @self stops bidding for every floor he bids for and gives up any he has, in
; whatever talk that is: the talk a line takes the floor of can change before the line ends.
(define-func release-floor ()
  (for-each ?talk (bb-public-every ? bidding @self)
    (bb-public-remove-member ?talk bidding @self))
  (for-each ?talk (bb-public-every ? answering @self)
    (bb-public-remove-member ?talk answering @self))
  (for-each ?talk (bb-public-every ? floor @self)
    (bb-public-clear ?talk floor)))

; (claim-turn ?audience) - @self takes his turn to speak to ?audience: the floor of the
; conversation he speaks in, and the marks on whom he speaks to.
(define-func claim-turn (?audience)
  (and (take-floor ?audience) (claim-addressees ?audience)))

; (speaking) - a line of @self's is being said: his SAY runs, and it holds his floor and marks
; until it ends however it ends (actions/SAY.mc), whatever stopped the tell that proposed it.
(define-func speaking ()
  (substantial (any {@self SAY ?})))

; (release-addressees ?audience) - @self's marks on ?audience and on himself clear; another man's
; stay.
(define-func release-addressees (?audience)
  (if (substantial (bb-public-any @self addressed @self))
      (then (bb-public-clear @self addressed)))
  (release-mark ?audience))

; (release-mark ?audience) - @self's mark on ?audience clears; another man's stays.
(define-func release-mark (?audience)
  (if (substantial ?audience)
      (then
        (if (substantial (bb-public-any ?audience addressed @self))
            (then (bb-public-clear ?audience addressed))))))

; (engaged-with ?partner) - @self and ?partner talk together: both are in one conversation, and
; since @self joined it a hail between them has been answered - his hail taken up, or ?partner's
; taken up by him. Being in one talk with a man is not yet talking to him.
(define-func engaged-with (?partner)
  (bind (conversation-of @self) ?talk)
  (bind (any {?talk participant @self}) ?part)
  (and (substantial ?talk)
       (in-conversation ?partner ?talk)
       (or (any-happened-since (every {@self hail ?partner /succ}) ?part)
           (any-happened-since (every {@self take-up ?partner /succ}) ?part))))

; (invited-by ?caller) - the hail ?caller called to @self stands: his hailing set holds @self.
; Whether it is answered is the reader's role: no take-up or turn-down of @self's caused by it has
; succeeded.
(define-func invited-by (?caller)
  (substantial (bb-public-any ?caller hailing @self)))

; (turned-away ?msg) - ?msg turns a hail down: a refusal or a rebuff.
(define-func turned-away (?msg)
  (and (eq-func-name ?msg formulaic)
       (or (eq (nth (k-formulaic-category-field) ?msg) refusal)
           (eq (nth (k-formulaic-category-field) ?msg) rebuff))))

; (hail-accepted ?partner ?hail) - ?partner answered the opening @self called in ?hail without
; turning it down, and the two are in one conversation.
(define-func hail-accepted (?partner ?hail)
  (bind (hail-reply ?partner ?hail) ?reply)
  (and (is-belief ?reply)
       (not (turned-away ?reply.target))
       (conversing-with ?partner @self)))

; (hail-turned-down ?partner ?hail) - ?partner answered the opening @self called in ?hail with a
; refusal or a rebuff.
(define-func hail-turned-down (?partner ?hail)
  (bind (hail-reply ?partner ?hail) ?reply)
  (and (is-belief ?reply) (turned-away ?reply.target)))

; (join-conversation ?talk) - @self takes part in ?talk: he joins its participant set, and he knows
; himself a party of it, where it is held when he did not yet, and the occasion it is part of when
; he holds one for here today. Joining the talk he is in already changes nothing.
(define-func join-conversation (?talk)
  (bb-public-add-member ?talk participant @self)
  (if (unsubstantial (any {?talk participant @self}))
      (then (begin-belief {?talk participant @self})))
  (if (unsubstantial (any {?talk venue ?}))
      (then (begin-belief {?talk venue (spatial @self space)})))
  (bind (o /known [k occasion] {@o venue (spatial @self building)} {@o held-on (time date)}) ?occasion)
  (if (and (substantial ?occasion) (unsubstantial (any {?talk occasion ?})))
      (then (begin-belief {?talk occasion ?occasion}))))

; (open-conversation) - @self opens a conversation where he stands: a new shared object, and
; himself in it. Taking up a hail makes one when neither man is in a conversation.
(define-func open-conversation ()
  (share-object (o /invent [k conversation])): ?talk
  (join-conversation ?talk)
  ?talk)

; (parties-of ?talk) - every party in ?talk: its participant set.
(define-func parties-of (?talk)
  (bb-public-members ?talk participant))

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

; (leave-conversation ?talk) - @self leaves the conversation ?talk: he comes off its participant
; and has-more sets, and his part in it and his knowing where it is held end.
(define-func leave-conversation (?talk)
  (if (substantial ?talk)
      (then
        (if (not (speaking))
            (then (release-floor)))
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
; not empty he shows it - he is in the conversation's has-more set (thinks/
; conversation-has-more-think.mc) - and comes off it when it is (conversation-said-all-think.mc).
; He is done with a conversation when his agenda is empty and its has-more set is (said-all): the
; last to run out takes his leave, and his goodbye wakes the rest.

; (asked-news ?friend ?talk) - @self has asked ?friend what is new since he joined ?talk.
(define-func asked-news (?friend ?talk)
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?asked)
  (if (substantial ?part)
      (then
        (for-each ?ask (every {@self SAY (qs ? (pick-untold-belief ?..)) ?friend /succ})
          (if (happened-since ?ask ?part)
              (then (bind @true ?asked) (break))))))
  ?asked)

; (replied ?speaker ?said) - ?speaker has said something to @self in reply to @self's line ?said: a
; line of his caused by it.
(define-func replied (?speaker ?said)
  (substantial (any {?speaker SAY ? @self /succ /caused_by ?said})))

; (hail-reply ?partner ?hail) - what ?partner said in reply to the opening @self called in ?hail,
; or @fail.
(define-func hail-reply (?partner ?hail)
  (bind (any {@self SAY (formulaic ? opening-phrase ?..) ?partner /succ /caused_by ?hail}) ?said)
  (if (is-belief ?said)
      (then (any {?partner SAY ? @self /succ /caused_by ?said}))
      (else @fail)))

; (inquiry-of ?fact) - the question that searches the fact clause ?fact.
(define-func inquiry-of (?fact)
  (qs /utterable [/msg-class inquiry] (any ?fact)))

; (askable ?who ?fact) - @self may ask ?who for the fact clause ?fact: he could know it, and @self
; does not take him not to know it.
(define-func askable (?who ?fact)
  (and (could-know ?who ?fact) (none {?who /not know ?fact})))

; (wants-to-ask ?party) - @self wonders about something ?party could tell him.
(define-func wants-to-ask (?party)
  (bind @false ?asks)
  (for-each ?wonder (every {@self wonder ?})
    (if (askable ?party ?wonder.target)
        (then (bind @true ?asks) (break))))
  ?asks)

; (speech-worthy ?belief ?friend) - @self may tell ?friend the belief ?belief and believes he does
; not know it: its tier admits him, @self does not take him to know it, and either takes him not
; to or does not presume him to.
(define-func speech-worthy (?belief ?friend)
  (and (is-belief ?belief)
       (disclosable-to ?belief ?friend)
       (none {?friend know (clausify ?belief)})
       (or (substantial (any {?friend /not know (clausify ?belief)}))
           (not (presumed-known ?belief ?friend)))))

; (news-for ?friend) - the first piece of @self's news ?friend does not know, or @nothing.
(define-func news-for (?friend)
  (bind @nothing ?pick)
  (for-each ?news (every {@self news ?})
    (if (speech-worthy ?news.target ?friend)
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

; (gossip-for ?friend) - the first piece of gossip @self holds that ?friend does not know, about
; someone @self can name, or @nothing.
(define-func gossip-for (?friend)
  (bind @nothing ?pick)
  (for-each ?gossip (every {@self gossip ?})
    (bind ?gossip.target ?heard)
    (if (and (is-belief ?heard)
             (substantial (any {?heard.subject name ?}))
             (speech-worthy ?heard ?friend))
        (then (bind ?heard ?pick) (break))))
  ?pick)

; (asked-and-answered ?friend ?talk) - @self asked ?friend what is new in ?talk and has his reply.
(define-func asked-and-answered (?friend ?talk)
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?answered)
  (if (substantial ?part)
      (then
        (for-each ?ask (every {@self SAY (qs ? (pick-untold-belief ?..)) ?friend /succ})
          (if (and (happened-since ?ask ?part) (replied ?friend ?ask))
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
  (for-each ?smalltalk (every {@self smalltalk ?talk ? /ever})
    (if (substantial (any {@self tell (msg ~[/msg-class smalltalk] ?..) ? /succ /caused_by ?smalltalk}))
        (then (bind @true ?remarked) (break))))
  ?remarked)

; Every line said to a man makes a response from him relevant, and its kind decides which: a
; question an answer, an opening an opening's answer, a flirt a flirt's answer, a remark a remark
; or agreement, tidings tidings of his own or a receipt. A response itself calls for none. The
; respond driver (drivers/respond-driver.mc) owes it, the respond task says it, caused by the line.

; (line-kind ?msg) - the kind of move ?msg is: inquiry (a question), opening-phrase (a hail),
; flirtation (a flirt), smalltalk (a remark), tidings (news), or reply - anything that answers a
; line rather than calling for an answer.
(define-func line-kind (?msg)
  (cond (case (is-qs ?msg) inquiry)
        (case (eq-func-name ?msg formulaic)
              (switch (nth (k-formulaic-category-field) ?msg)
                (on opening-phrase opening-phrase)
                (on flirt (flip (eq (nth (k-formulaic-key-field) ?msg) compliment) flirtation reply))
                (else reply)))
        (else
          (switch (msg-class-of ?msg)
            (on smalltalk smalltalk)
            (on tidings tidings)
            (else reply)))))

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
      (then (bind (pick-untold-belief /news ?speaker) ?news)))
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

; (awaits-smalltalk-answer ?talk ?partner) - a smalltalk remark ?partner made to @self in ?talk is
; still unanswered.
(define-func awaits-smalltalk-answer (?talk ?partner)
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?waiting)
  (for-each ?line (every {?partner SAY (msg ~[/msg-class smalltalk] ?..) @self /past})
    (if (and (happened-since ?line ?part) (none {@self tell ? ?partner /succ /caused_by ?line}))
        (then (bind @true ?waiting) (break))))
  ?waiting)

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
  (for-each ?flirt (every {@self flirt ?talk ? /ever})
    (if (substantial (any {@self tell (formulaic ~[/msg-class flirtation] flirt compliment) ? /succ /caused_by ?flirt}))
        (then (bind @true ?flirted) (break))))
  ?flirted)

; (awaits-flirt-answer ?talk ?partner) - a flirt ?partner made to @self in ?talk is still unanswered.
(define-func awaits-flirt-answer (?talk ?partner)
  (bind (any {?talk participant @self}) ?part)
  (bind @false ?waiting)
  (for-each ?line (every {?partner SAY (formulaic ~[/msg-class flirtation] flirt compliment) @self /past})
    (if (and (happened-since ?line ?part) (none {@self tell ? ?partner /succ /caused_by ?line}))
        (then (bind @true ?waiting) (break))))
  ?waiting)

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
  (bind (or (substantial (any {@self smalltalk|flirt ?talk ?}))
            (and (substantial (any {@self unease ?talk})) (substantial (smalltalk-line ?talk))))
        ?more)
  (for-each ?party (parties-of ?talk)
    (if (and (not ?more) (neq ?party @self))
        (then
          (bind (or (substantial (any {@self inquire ?party ?}))
                    (substantial (any {@self respond ?party ?}))
                    (substantial (any {@self catch-up|tell-gossip|get-acquainted ?party}))
                    (wants-to-ask ?party)
                    (substantial (news-for ?party))
                    (substantial (gossip-for ?party)))
                ?more))))
  ?more)

; (said-all ?talk) - nobody in ?talk has anything left to say, @self included.
(define-func said-all (?talk)
  (if (substantial ?talk)
      (then (and (not (agenda-for ?talk)) (bb-public-none ?talk has-more)))
      (else @false)))

; (answer-to ?qs ?partner) - what @self says to ?partner's question ?qs: its content evaluated in
; his mind, or "nothing much" when it asked his news and he has none.
(define-func answer-to (?qs ?partner)
  (bind (eval-msg /output_unknown_on_fail ?qs ?partner) ?answer)
  (bind (nth (k-msg-first-content-field) ?qs) ?asked-content)
  (if (and (eq-func-name ?asked-content pick-untold-belief) (unsubstantial ?answer))
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

; (took-up ?caller) - @self took up a conversation ?caller opened, and has hailed ?caller
; himself no time since: the open conversation is ?caller's, not one @self opened.
(define-func took-up (?caller)
  (bind @nothing ?found)
  (for-each ?take-up (every {@self take-up ?caller /succ})
    (if (not (any-happened-since (every {@self hail ?caller /past}) ?take-up))
        (then
          (bind @true ?found)
          (break))))
  ?found)

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
  (and (conversing-with ?npc @self) (in-earshot ?npc [k speech])))

; (player-hail ?npc ?authority) - the player opens a conversation with ?npc, or joins the one
; ?npc is in: he joins its participant set, and the answer is the line he hails him with -
; plainly, or, when ?authority names the kind of his job, introducing himself by it. The player
; holds no beliefs, so his conversation is the shared object alone, kept by its board.
(define-func player-hail (?npc ?authority)
  (bind (conversation-of ?npc) ?theirs)
  (if (substantial ?theirs)
      (then (bb-public-add-member ?theirs participant @self))
      (else
        (share-object (o /invent [k conversation])): ?talk
        (bb-public-add-member ?talk participant @self)))
  (if (is-kind ?authority)
      (then (formulaic [] opening-phrase authority ?authority))
      (else (formulaic [] opening-phrase player_talk))))

; (player-leave-taking ?npc) - the player leaves the conversation with ?npc, and the answer is
; the line he takes his leave with. He comes off its participant set.
(define-func player-leave-taking (?npc)
  (bind (conversation-of @self) ?talk)
  (if (substantial ?talk)
      (then (bb-public-remove-member ?talk participant @self)))
  (formulaic [] leave_taking player_bye))
