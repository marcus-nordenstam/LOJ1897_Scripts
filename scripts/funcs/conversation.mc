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
; holds his own copy of it, linked to the one the world keeps. The live contract is on the public
; blackboard: each party's (conversing ..) names the conversation while he takes part, and the
; conversation's own board holds its venue, which keeps it alive. Fellow participants are the
; parties whose entry names the same conversation - object identity, nothing more. Each party
; clears his own entry when he leaves (leave-conversation), and the last to leave clears the
; conversation's board, which releases it. What a man knows of a talk is his own beliefs:
; {<talk> participant <party>} for each party, one interval per spell, {<talk> venue <space>}
; over its span, {<talk> occasion <occasion>} when it is part of one.
;
; A HAIL is a (formulaic opening-phrase ..) said to @self by a man whose (conversing ..) names a
; conversation @self is not in. It is always answered, and how is his choice: he takes up the
; conversation, declines it for what he is busy with, or rebuffs a man he despises
; (drivers/answer-hail-driver.mc).
;
; The funcs at the foot are the player's side, asked by the host: whom he can hail, his
; opening and parting lines, and whether a man has taken him up.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")
(include "../macros/formulaic-macros.mc")

; (standing-before ?partner) - @self stands with ?partner to talk: within earshot of his
; speaking voice, on the spot before him (stand-spot-before), where go to a man brings him.
(define-func standing-before (?partner)
  (and (in-earshot ?partner [k speech]) (walked-before ?partner)))


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

; (said-to-me-since ?speaker ?since) - ?speaker has said something to @self since ?since.
(define-func said-to-me-since (?speaker ?since)
  (any-happened-since (every {?speaker SAY ? @self /past}) ?since))

; (conversation-of ?party) - the conversation ?party's public (conversing ..) names, or @fail.
(define-func conversation-of (?party)
  (bb-public-read ?party conversing))

; (in-conversation ?party ?talk) - ?party's entry names ?talk.
(define-func in-conversation (?party ?talk)
  (eq (bb-public-read ?party conversing) ?talk))

; (conversing-with ?party ?partner) - both take part in one conversation.
(define-func conversing-with (?party ?partner)
  (bind (bb-public-read ?party conversing) ?talk)
  (and (substantial ?talk) (in-conversation ?partner ?talk)))

; (unanswered-hail ?caller) - an opening ?caller called to @self stands unanswered: @self has
; neither taken him up nor turned him down since he called it.
(define-func unanswered-hail (?caller)
  (bind @false ?open)
  (for-each ?opening (every {?caller SAY (formulaic ? opening-phrase ?..) @self /past})
    (if (and (not (any-happened-since (every {@self take-up ?caller /succ}) ?opening))
             (not (any-happened-since (every {@self turn-down ?caller ? /succ}) ?opening)))
        (then (bind @true ?open) (break))))
  ?open)

; (invited-by ?caller) - ?caller is in a conversation, the one @self is in or another, and his
; hail stands unanswered: it is @self's to answer. A hail answered stays answered until he calls
; again.
(define-func invited-by (?caller)
  (and (substantial (bb-public-read ?caller conversing)) (unanswered-hail ?caller)))

; (join-conversation ?talk) - @self takes part in ?talk: his entry names it, and he knows himself
; a party of it, where it is held when he did not yet, and the occasion it is part of when he
; holds one for here today. Joining the talk he is in already changes nothing.
(define-func join-conversation (?talk)
  (bb-public-write @self conversing ?talk)
  (if (unsubstantial (any {?talk participant @self}))
      (then (begin-belief {?talk participant @self})))
  (if (unsubstantial (any {?talk venue ?}))
      (then (begin-belief {?talk venue (spatial @self space)})))
  (bind (o /known [k occasion] {@o venue (spatial @self building)} {@o held-on (time date)}) ?occasion)
  (if (and (substantial ?occasion) (unsubstantial (any {?talk occasion ?})))
      (then (begin-belief {?talk occasion ?occasion}))))

; (open-conversation) - @self opens a conversation where he stands: a new shared object, its
; venue on its board, and himself in it. The conversation it returns is what his hail names.
(define-func open-conversation ()
  (share-object (o /invent [k conversation])): ?talk
  (bb-public-write ?talk venue (spatial @self space))
  (join-conversation ?talk)
  ?talk)

; (other-party-in ?talk) - a party @self knows to be in ?talk, besides himself, still has his
; entry naming it.
(define-func other-party-in (?talk)
  (bind @false ?still)
  (for-each ?party (every {?talk participant ?})
    (bind ?party.target ?who)
    (if (and (neq ?who @self) (in-conversation ?who ?talk))
        (then (bind @true ?still) (break))))
  ?still)

; (leave-conversation) - @self leaves the conversation his entry names: the entry clears and
; his part in it ends; the last to leave ends its venue and clears its board, which releases
; it.
(define-func leave-conversation ()
  (bind (bb-public-read @self conversing) ?talk)
  (if (substantial ?talk)
      (then
        (bb-public-clear @self conversing)
        (end-belief {?talk participant @self})
        (if (not (other-party-in ?talk))
            (then
              (end-belief {?talk venue ?})
              (bb-public-clear ?talk venue))))))

; (agenda-answered ?partner ?agenda ?converse) - ?agenda has been told to ?partner in
; ?converse, and, when it asked something, he has answered since.
(define-func agenda-answered (?partner ?agenda ?converse)
  (bind (any {@self tell ?agenda ?partner /succ /caused_by ?converse}) ?told)
  (and (is-belief ?told)
       (or (not (is-qs ?agenda)) (said-to-me-since ?partner ?told))))

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
; ?npc is in: his own (conversing ..) names it, and the answer is the line he hails him with -
; plainly, or, when ?authority names the kind of his job, introducing himself by it. The player
; holds no beliefs, so his conversation is the shared object alone, its venue on its board.
(define-func player-hail (?npc ?authority)
  (bind (bb-public-read ?npc conversing) ?theirs)
  (if (substantial ?theirs)
      (then (bb-public-write @self conversing ?theirs))
      (else
        (share-object (o /invent [k conversation])): ?talk
        (bb-public-write ?talk venue (spatial @self space /env))
        (bb-public-write @self conversing ?talk)))
  (if (is-kind ?authority)
      (then (formulaic [] opening-phrase authority ?authority))
      (else (formulaic [] opening-phrase player_talk))))

; (player-leave-taking ?npc) - the player leaves the conversation with ?npc, and the answer is
; the line he takes his leave with. His entry clears; the conversation's board clears with it
; when ?npc has left too, or never joined.
(define-func player-leave-taking (?npc)
  (bind (bb-public-read @self conversing) ?talk)
  (bb-public-clear @self conversing)
  (if (and (substantial ?talk) (not (in-conversation ?npc ?talk)))
      (then (bb-public-clear ?talk venue)))
  (formulaic [] leave_taking player_bye))
