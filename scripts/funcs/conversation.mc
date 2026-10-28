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

; (standing-to-talk ?partner) - @self stands with ?partner to talk: within earshot of his speaking
; voice, on the spot go to a man for earshot walked him onto (earshot-spot-of) - before him, or
; beside him when his front is taken.
(define-func standing-to-talk (?partner)
  (and (in-earshot ?partner [k speech]) (walked-to-earshot-spot-of ?partner)))


; (call-msg ?msg) - ?msg is called out rather than spoken: a hail, and the answers to one.
(define-func call-msg (?msg)
  (and (eq-func-name ?msg formulaic)
       (or (eq (nth (k-formulaic-category-field) ?msg) opening-phrase) (eq (nth (k-formulaic-category-field) ?msg) response)
           (eq (nth (k-formulaic-category-field) ?msg) refusal) (eq (nth (k-formulaic-category-field) ?msg) rebuff))))

; (speech-sound ?msg) - the sound saying ?msg makes: a [k shout] called out, else [k speech].
(define-func speech-sound (?msg)
  (flip (call-msg ?msg) [k shout] [k speech]))

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
          (if (and (neq ?who @self) (not (in-earshot ?who (speech-sound ?msg))))
              (then (bind @false ?all-hear))))
        ?all-hear)
      (else (in-earshot ?listener (speech-sound ?msg)))))

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

; A man being spoken to carries the speaker's mark on his public board (addressed) while a line
; to him is being said, and a line said to a conversation marks the conversation: nobody is ever
; spoken to by two men at once, while men speak at once to different listeners freely. tell
; claims the mark when it proposes the SAY (claim-addressees) and clears it however it ends
; (release-addressees); a tell whose listener is spoken to waits (free-to-address), woken by the
; clear. Two men claiming one listener in one deliberation round is decided by the claim itself:
; the loser thinks again on the board the winner left. SAY asserts it holds the mark (holds-address).

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

; (claim-addressees ?audience) - @self marks ?audience as spoken to, @true, or leaves it as it was,
; @false, when another man is speaking to it or to anyone it reaches. A mark already his stands.
(define-func claim-addressees (?audience)
  (bind @true ?claimed)
  (if (and (substantial ?audience) (not (holds-address ?audience)))
      (then
        (bind (substantial (bb-public-try-write-new ?audience addressed @self)) ?claimed)
        (if (and ?claimed (not (free-to-address ?audience)))
            (then
              (release-addressees ?audience)
              (bind @false ?claimed)))))
  ?claimed)

; (release-addressees ?audience) - @self's mark on ?audience clears; another man's stays.
(define-func release-addressees (?audience)
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

; (invited-by ?caller) - ?caller is in a conversation, the one @self is in or another: the hail he
; called stands. Whether it is answered is the reader's role: no take-up or turn-down of @self's
; caused by it has succeeded.
(define-func invited-by (?caller)
  (substantial (conversation-of ?caller)))

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
; himself in it. The conversation it returns is what his hail names.
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

; (leave-conversation) - @self leaves the conversation he takes part in: he comes off its
; participant and has-more sets, and his part in it and his knowing where it is held end.
(define-func leave-conversation ()
  (bind (conversation-of @self) ?talk)
  (if (substantial ?talk)
      (then
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

; (friend-talks ?talk ?friend) - every friend-talk @self has held with ?friend in ?talk.
(define-func friend-talks (?talk ?friend)
  (every {@self friend-talk ?talk ?friend /ever}))

; (asked-news ?friend ?talk) - @self has asked ?friend what is new in his friend-talk in ?talk.
(define-func asked-news (?friend ?talk)
  (bind @false ?asked)
  (for-each ?friend-talk (friend-talks ?talk ?friend)
    (if (substantial (any {@self SAY (qs ? (pick-untold-belief ?..)) ?friend /succ /caused_by ?friend-talk}))
        (then (bind @true ?asked) (break))))
  ?asked)

; (friend-awaits-reply ?talk ?friend) - @self asked ?friend something in his friend-talk in ?talk
; and has had no reply to it yet.
(define-func friend-awaits-reply (?talk ?friend)
  (bind @false ?waiting)
  (for-each ?friend-talk (friend-talks ?talk ?friend)
    (for-each ?said (every {@self SAY (qs ? ? ?..) ?friend /succ /caused_by ?friend-talk})
      (if (not (replied ?friend ?said))
          (then (bind @true ?waiting) (break)))))
  ?waiting)

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

; (supper-hour-question ?cook) - the question @self has for the woman of his house while he does
; not know its supper hour and does not take her not to know it, or @nothing.
(define-func supper-hour-question (?cook)
  (bind @nothing ?line)
  (bind (any {@self home ?}) ?home-belief)
  (if (is-belief ?home-belief)
      (then
        (bind ?home-belief.target ?home)
        (if (and (substantial (any {@self mother|parent|spouse ?cook}))
                 (substantial (any {?cook gender [k female]}))
                 (none {?home supper-hour ?})
                 (none {?cook /not know {?home supper-hour ?}}))
            (then (bind (qs /utterable [/msg-class inquiry] (any {?home supper-hour ?})) ?line)))))
  ?line)

; (friend-talk-line ?talk ?friend) - the next FRIEND-TALK dialogue-line @self has for ?friend in
; ?talk, or @nothing: news of his ?friend has not heard, then asking what is new with him, then
; gossip he has not heard. Only to a friend, or someone closer, and only from twelve.
(define-func friend-talk-line (?talk ?friend)
  (bind @nothing ?line)
  (if (and (substantial (any {@self (closeness-labels friend) ?friend}))
           (>= (any {@self age ?}).target 12))
      (then
        (bind (pick-untold-belief /news ?friend) ?news)
        (if (substantial ?news)
            (then (bind (msg /utterable [/msg-class tidings] ?news) ?line))
            (else
              (if (not (asked-news ?friend ?talk))
                  (then (bind (qs /utterable [/msg-class tidings] (pick-untold-belief /news @i)) ?line))
                  (else
                    (bind (pick-untold-belief /gossip ?friend) ?gossip)
                    (if (substantial ?gossip)
                        (then (bind (msg /utterable [/msg-class tidings] ?gossip) ?line)))))))))
  ?line)

; (remarked-in ?talk) - @self has made his smalltalk remark in ?talk: one a talk.
(define-func remarked-in (?talk)
  (bind @false ?remarked)
  (for-each ?smalltalk (every {@self smalltalk ?talk ? /ever})
    (if (substantial (any {@self tell (msg ~[/msg-class smalltalk] ?..) ? /succ /caused_by ?smalltalk}))
        (then (bind @true ?remarked) (break))))
  ?remarked)

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
  (bind (or (substantial (any {@self friend-talk|smalltalk|flirt ?talk ?}))
            (and (substantial (any {@self unease ?talk})) (substantial (smalltalk-line ?talk))))
        ?more)
  (for-each ?party (parties-of ?talk)
    (if (and (not ?more) (neq ?party @self))
        (then
          (bind (or (substantial (any {@self inquire ?party ?}))
                    (substantial (any {@self answer ?party ?}))
                    (substantial (supper-hour-question ?party))
                    (substantial (friend-talk-line ?talk ?party)))
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
