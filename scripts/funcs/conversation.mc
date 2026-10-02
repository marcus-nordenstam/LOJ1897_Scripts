; ----------------------------------------------------------------------------
; conversation.mc - who hears whom, how a man answers being hailed, and how a conversation
; he opened goes.
;
; Speech has two tasks and no other rule proposes SAY: tell (tasks/tell-task.mc) says one
; thing where its audience can hear it, and converse (tasks/converse-task.mc) holds an
; exchange - it opens with a hail, says each of its lines through tell, and waits for the
; answers.
;
; A HAIL is a (formulaic opening ..) said to @self. It is always answered, and how is his
; choice: he takes up the conversation, declines it for what he is busy with, or rebuffs
; a man he despises. weigh-hail (thinks/hot/answer-hail-think.mc) makes that choice once
; through (hail-answer ..), so only one of the three answers is ever said.
;
; The funcs at the foot are the player's side, asked by the host: whom he can hail, his
; opening and parting lines, and whether a man has taken him up.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

; (in-earshot ?listener) - @self believes ?listener hears what he says: co-presence, which is
; what the hearing pass delivers a speech sound by.
(define-func in-earshot (?listener)
  (spatial ?listener co-located @self))

; (standing-before ?partner) - @self stands with ?partner to talk: in earshot, on the spot
; before him (stand-spot-before), where go to a man brings him.
(define-func standing-before (?partner)
  (and (in-earshot ?partner) (walked-before ?partner)))

; (call-msg ?msg) - ?msg is called out rather than spoken: a hail, and the answers to one.
; deliver-speech makes it a [k shout], which carries (k-call-earshot).
(define-func call-msg (?msg)
  (and (eq-func-name ?msg formulaic)
       (or (eq (nth 1 ?msg) opening) (eq (nth 1 ?msg) response)
           (eq (nth 1 ?msg) refusal) (eq (nth 1 ?msg) rebuff))))

; (within-call ?listener) - @self believes ?listener would hear him call out: seen in his space
; no further off than his voice carries, or heard calling to @self a moment ago - hearing a man
; tells you nothing of where he stands, but a voice that reached you can be answered.
(define-func within-call (?listener)
  (or (and (eq (spatial ?listener space) (spatial @self space))
           (<= (distance @self ?listener) (k-call-earshot)))
      (heard-calling ?listener)))

; (heard-calling ?caller) - ?caller called out to @self no more than (k-call-answer-seconds) ago.
(define-func heard-calling (?caller)
  (bind @nothing ?heard)
  (for-each ?call (every {?caller SAY ? @self /past})
    (if (and (call-msg ?call.target)
             (<= (elapsed /seconds ?call) (k-call-answer-seconds)))
        (then
          (bind @true ?heard)
          (break))))
  ?heard)

; (within-voice ?listener ?msg) - ?listener would hear @self say ?msg: called out, within
; call; spoken, in earshot. tell closes on its audience until this holds.
(define-func within-voice (?listener ?msg)
  (or (in-earshot ?listener)
      (and (call-msg ?msg) (within-call ?listener))))

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

; (hail-answer ?speaker ?busy) - how @self answers ?speaker's hail while ?busy, the top of
; the chain his legs or mouth serve (@fail when they serve none), is what he is doing:
; rebuff a man he despises and does not answer to; decline for anything worth more than
; the hail; else engage.
(define-func hail-answer (?speaker ?busy)
  (cond (case (and {@self despise ?speaker} (not (answers-to ?speaker))) rebuff)
        (case (and (is-belief ?busy) (> (utility ?busy) (hail-worth ?speaker))) decline)
        (else engage)))

; (engage-utility ?speaker ?busy) - what taking up ?speaker's hail runs at: its worth, raised
; past ?busy when that is what he sets aside for it, since a tie goes to the act running.
(define-func engage-utility (?speaker ?busy)
  (if (is-belief ?busy)
      (then (max (hail-worth ?speaker) (+ (utility ?busy) (k-converse-margin))))
      (else (hail-worth ?speaker))))

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

; (hail-answered ?heard ?speaker) - @self has finished saying something to ?speaker since he
; heard the hail ?heard.
(define-func hail-answered (?heard ?speaker)
  (any-happened-since (every {@self SAY ? ?speaker /past}) ?heard))

; (engaged-with ?partner) - ?partner has taken up @self's hail and is talking with him.
(define-func engaged-with (?partner)
  (eq (bb-public-read ?partner conversing) @self))

; (converse-began ?partner ?converse) - when @self's conversation with ?partner began: the
; goal he took it up for, else the converse itself.
(define-func converse-began (?partner ?converse)
  (bind (any {@self goal {@self converse ?partner}}) ?goal)
  (if (is-belief ?goal) (then ?goal) (else ?converse)))

; (hail-turned-down ?partner ?converse) - ?partner has answered the hail @self opened ?converse
; with, and not by taking it up.
(define-func hail-turned-down (?partner ?converse)
  (bind (any {@self tell (formulaic opening ?) ?partner /succ /caused_by ?converse}) ?hail)
  (and (is-belief ?hail)
       (not (engaged-with ?partner))
       (said-to-me-since ?partner ?hail)))

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

; (can-hail ?thing) - the player can hail ?thing: a living man within call, as the world has
; it - the player holds no beliefs. Only distance bounds a call: the host asks about the man
; under the aim dot, whom the player sees, whatever space he stands in. The host shows its
; Talk hint and lets T hail him on it.
(define-func can-hail (?thing)
  (and (is-a ?thing [k human])
       (neq (attr ?thing condition) [k dead])
       (<= (distance @self ?thing) (k-call-earshot))))

; (engaged-here ?npc) - ?npc has taken up the player's hail and come to him: the host opens
; the dialogue on it, and not while he is still on his way.
(define-func engaged-here (?npc)
  (and (engaged-with ?npc) (spatial ?npc co-located @self /env)))

; (player-opening) - the line the player hails a man with.
(define-func player-opening ()
  (formulaic opening player_talk))

; (player-leave-taking) - the line the player takes his leave with.
(define-func player-leave-taking ()
  (formulaic leave_taking player_bye))
