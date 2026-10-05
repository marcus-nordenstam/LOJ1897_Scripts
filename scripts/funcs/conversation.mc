; ----------------------------------------------------------------------------
; conversation.mc - who hears whom, how a man answers being hailed, and how a conversation
; he opened goes.
;
; Speech has two tasks and no other rule proposes SAY: tell (tasks/tell-task.mc) says one
; thing where its audience can hear it, and converse (tasks/converse-task.mc) holds an
; exchange - it opens with a hail, says each of its lines through tell, and waits for the
; answers.
;
; A CONVERSATION is a contract on the public blackboard: each party's (conversing ..) names
; the other while he takes part. The hailer posts his before he hails; the man hailed posts
; his when he takes it up. Whoever ends it - declining, rebuffing, taking his leave, giving up
; - clears both (end-conversation), and each party knows it is over when his own entry no
; longer names the other.
;
; A HAIL is a (formulaic opening ..) said to @self by a man whose (conversing ..) names him.
; It is always answered, and how is his choice: he takes up the conversation, declines it
; for what he is busy with, or rebuffs a man he despises (thinks/hot/answer-hail-think.mc).
;
; The funcs at the foot are the player's side, asked by the host: whom he can hail, his
; opening and parting lines, and whether a man has taken him up.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; (standing-before ?partner) - @self stands with ?partner to talk: within earshot of his
; speaking voice, on the spot before him (stand-spot-before), where go to a man brings him.
(define-func standing-before (?partner)
  (and (in-earshot ?partner [k speech]) (walked-before ?partner)))

; (call-msg ?msg) - ?msg is called out rather than spoken: a hail, and the answers to one.
(define-func call-msg (?msg)
  (and (eq-func-name ?msg formulaic)
       (or (eq (nth 1 ?msg) opening) (eq (nth 1 ?msg) response)
           (eq (nth 1 ?msg) refusal) (eq (nth 1 ?msg) rebuff))))

; (speech-sound ?msg) - the sound saying ?msg makes: a [k shout] called out, else [k speech].
(define-func speech-sound (?msg)
  (if (call-msg ?msg) (then [k shout]) (else [k speech])))

; (within-call ?listener) - ?listener would hear @self call out, as @self knows where he
; stands - seen, or heard: a voice places the man it came from.
(define-func within-call (?listener)
  (in-earshot ?listener [k shout]))

; (within-voice ?listener ?msg) - ?listener would hear @self say ?msg. tell closes on its
; audience until this holds.
(define-func within-voice (?listener ?msg)
  (in-earshot ?listener (speech-sound ?msg)))

; (answers-to ?speaker) - @self is bound to heed ?speaker's hail: his master, his mother or
; his father.
(define-func answers-to (?speaker)
  (or {@self master ?speaker} {@self mother ?speaker} {@self father ?speaker}))

; (hail-worth ?speaker) - what taking up ?speaker's hail is worth to @self, as a packed
; utility: an obligation when he answers to ?speaker, else a want that rises with how close
; they are.
(define-func hail-worth (?speaker)
  (cond (case (answers-to ?speaker) (utility obligation (k-hail-bond-value)))
        (case {@self spouse|lover|friend|close-to|mother|father|child|sibling ?speaker}
              (utility want (k-hail-bond-value)))
        (case {@self acquaintance ?speaker} (utility want (k-hail-acquaintance-value)))
        (else (utility want (k-hail-stranger-value)))))

; (rebuffs ?speaker) - @self rebuffs ?speaker's hail: he despises him and does not answer to him.
(define-func rebuffs (?speaker)
  (and {@self despise ?speaker} (not (answers-to ?speaker))))

; (would-engage ?speaker) - talking with ?speaker is worth more to @self than anything else he
; has going: the conversation would win selection now.
(define-func would-engage (?speaker)
  (> (hail-worth ?speaker) (top-competing-utility {@self converse ?speaker})))

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

; (conversing-with ?party ?partner) - ?party takes part in a conversation with ?partner: his
; public (conversing ..) names him.
(define-func conversing-with (?party ?partner)
  (eq (bb-public-read ?party conversing) ?partner))

; (invited-by ?caller) - ?caller has opened a conversation with @self that @self has not yet
; taken up: the hail is his to answer.
(define-func invited-by (?caller)
  (and (conversing-with ?caller @self) (not (conversing-with @self ?caller))))

; (end-conversation ?partner) - @self ends the conversation with ?partner, for both of them.
(define-func end-conversation (?partner)
  (if (conversing-with @self ?partner) (then (bb-public-clear @self conversing)))
  (if (conversing-with ?partner @self) (then (bb-public-clear ?partner conversing))))

; (agenda-answered ?partner ?agenda ?converse) - ?agenda has been told to ?partner in
; ?converse, and, when it asked something, he has answered since.
(define-func agenda-answered (?partner ?agenda ?converse)
  (bind (any {@self tell ?agenda ?partner /succ /caused_by ?converse}) ?told)
  (and (is-belief ?told)
       (or (not (is-qs ?agenda)) (said-to-me-since ?partner ?told))))

; (converse-concluded ?partner) - the converse task @self took up for his converse goal with
; ?partner has ended.
(define-func converse-concluded (?partner)
  (any-happened-since (every {@self converse ?partner /past})
                      (any {@self goal {@self converse ?partner}})))

; (can-hail ?thing) - the player can hail ?thing: a living man who would hear him call out, as
; the world has it - the player holds no beliefs. The host shows its Talk hint and lets T hail
; him on it.
(define-func can-hail (?thing)
  (and (is-a ?thing [k human])
       (neq (attr ?thing condition) [k dead])
       (within-call ?thing)))

; (engaged-here ?npc) - ?npc has taken up the player's hail and come within earshot of his
; speaking voice: the host opens the dialogue on it, and not while he is still on his way.
(define-func engaged-here (?npc)
  (and (conversing-with ?npc @self) (in-earshot ?npc [k speech])))

; (player-hail ?npc) - the player opens a conversation with ?npc: his own (conversing ..)
; names him, and the answer is the line he hails him with.
(define-func player-hail (?npc)
  (bb-public-write @self conversing ?npc)
  (formulaic opening player_talk))

; (player-leave-taking ?npc) - the player ends the conversation with ?npc, and the answer is
; the line he takes his leave with.
(define-func player-leave-taking (?npc)
  (end-conversation ?npc)
  (formulaic leave_taking player_bye))
