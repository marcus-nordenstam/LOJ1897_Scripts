; ----------------------------------------------------------------------------
; witness - what a man can tell of a place and a time from his own episodes: who was there, what
; someone was doing, and what he saw done. Each answer is read off the episodes the place index
; finds, the man's own links deciding which acts are the top of their chains (W1 ruling 10).
; ----------------------------------------------------------------------------

; ?belief is an act - a task or an action - rather than a state.
(define-func is-act (?belief)
  (or (is-a ?belief.label [k task]) (is-a ?belief.label [k action])))

; ?act is the top of its chain as the man holds it: no act of its actor's is among its causes - the
; drink, not the grasp the drink explains.
(define-func top-act (?act)
  (empty (every ?cause {?act.subject ? ? /ever}
           (where (and (is-act ?cause) (substantial (caused-by ?act ?cause)))))))

; The people the man places at ?where during ?when - an episode's actor, and anyone it names whom
; the look that saw it showed him - each once, himself left out. @unknown when he cannot say where.
(define-func who-was-there (?where ?when)
  (if (unsubstantial ?where)
      (then @unknown)
      (else (every ?who {?who ? ? /during ?when /at ?where}
                        {? ? ?who /during ?when /at ?where}
                        {? ? ? ?who /during ?when /at ?where}
              (where (and (is-object ?who) (is-a ?who [k human]) (!= ?who @self)))))))

; What ?who was doing during ?when, as the man holds it: the acts of his in that time that are the
; top of their chains.
(define-func doing-during (?who ?when)
  (every ?act {?who ? ? /during ?when}
    (where (and (is-act ?act) (top-act ?act)))))

; The acts the man holds done at ?where during ?when by anyone but himself, each the top of its chain.
(define-func what-was-seen (?where ?when)
  (every ?act {? ? ? /during ?when /at ?where}
    (where (and (is-object ?act.subject) (!= ?act.subject @self) (is-act ?act) (top-act ?act)))))

; TELLING - what he saw done, as a line of beats (W1 rulings 15-20), in the order they began, at
; most (k-told-beats). A line that tells what was going on is said progressive ([/aspect
; progressive]), one beat for each run of one act - the same actor doing the same thing to the same
; kind of thing - and a run of (k-kept-times) or more said as what kept going on ([/aspect
; iterative]: "kept drinking claret"). A line that tells what happened is told blow by blow: one beat for each stretch
; of a run whose acts follow one another, its count said ([/times n]: "drank claret twice"), and a
; stretch of a run told before, something else between, said again ([/again]). Each beat is a line
; of its own, hedged by its own riders: told when a line told it him ([/told <the line>]), else as
; sure as he is of it; and "as she often does" when he holds a habit of its run ([/habitual
; <times>], a merged memory). @unknown when he holds no act to tell.

; The kind of thing ?thing is, or ?thing itself when it is no thing he holds.
(define-func thing-kind (?thing)
  (flip (is-object ?thing) (kind ?thing) ?thing))

; ?act and ?other are of one run: the same actor doing the same thing to the same kind of thing.
(define-func same-run (?act ?other)
  (and (eq ?act.subject ?other.subject)
       (eq ?act.label ?other.label)
       (eq (thing-kind ?act.target) (thing-kind ?other.target))))

; ?act began before ?other, a start he never saw coming last.
(define-func began-before (?act ?other)
  (bind (start-time ?act) ?began)
  (bind (start-time ?other) ?other-began)
  (cond (case (unknown ?began) @false)
        (case (unknown ?other-began) @true)
        (else (< ?began ?other-began))))

; ?act began first of its run among ?acts.
(define-func run-first (?act ?acts)
  (bind @true ?first)
  (for-each ?other ?acts
    (if (and (same-run ?act ?other) (began-before ?other ?act))
        (then (bind @false ?first) (break))))
  ?first)

; How many acts of ?act's run are among ?acts.
(define-func run-count (?act ?acts)
  (bind 0 ?count)
  (for-each ?other ?acts
    (if (same-run ?act ?other) (then (bind (+ ?count 1) ?count))))
  ?count)

; The act of ?acts that began last before ?act (?later @false), or first after it (?later @true);
; @nothing when none did.
(define-func act-beside (?act ?acts ?later)
  (bind @nothing ?beside)
  (for-each ?other ?acts
    (bind (cond (case ?later (began-before ?act ?other)) (else (began-before ?other ?act))) ?side)
    (bind (cond (case (unsubstantial ?beside) @true)
                (case ?later (began-before ?other ?beside))
                (else (began-before ?beside ?other)))
          ?nearer)
    (if (and (neq ?other ?act) ?side ?nearer)
        (then (bind ?other ?beside))))
  ?beside)

; ?act begins a stretch of its run among ?acts: the act before it is of another run, or there is none.
(define-func stretch-first (?act ?acts)
  (bind (act-beside ?act ?acts @false) ?before)
  (cond (case (unsubstantial ?before) @true)
        (else (not (same-run ?act ?before)))))

; How many acts of ?act's run follow one another from ?act, nothing else between, ?act among them.
(define-func stretch-count (?act ?acts)
  (bind 1 ?count)
  (bind ?act ?at)
  (repeat (count ?acts)
    (bind (act-beside ?at ?acts @true) ?at)
    (if (cond (case (unsubstantial ?at) @true) (else (not (same-run ?act ?at))))
        (then (break)))
    (bind (+ ?count 1) ?count))
  ?count)

; ?act begins a beat of the telling: what was going on, the first of its run; what happened, the
; first of a stretch.
(define-func beat-first (?act ?acts ?progressive)
  (flip ?progressive (run-first ?act ?acts) (stretch-first ?act ?acts)))

; How many acts that begin beats, at the instant ?act began, come before ?act in ?acts.
(define-func tie-index (?act ?acts ?progressive)
  (bind 0 ?index)
  (for-each ?other ?acts
    (cond (case (eq ?other ?act) (break))
          (case (and (eq (start-time ?other) (start-time ?act)) (beat-first ?other ?acts ?progressive))
                (bind (+ ?index 1) ?index))))
  ?index)

; ?act is told after the ?beats told so far, the last of them begun at ?after, the ?ties-th of
; those begun then.
(define-func told-later (?act ?acts ?progressive ?after ?ties ?beats)
  (bind (start-time ?act) ?began)
  (cond (case (= ?beats 0) @true)
        (case (eq ?began ?after) (>= (tie-index ?act ?acts ?progressive) ?ties))
        (case (unknown ?after) @false)
        (case (unknown ?began) @true)
        (else (> ?began ?after))))

; The line a man told @self ?belief in, or @nothing when he saw it himself.
(define-func told-line (?belief)
  (bind @nothing ?line)
  (for-each ?source (sources ?belief)
    (if (and (is-belief ?source) (eq ?source.label SAY))
        (then (bind ?source ?line) (break))))
  ?line)

; The beat ?said that tells ?act, hedged: told - by ?asker himself, @you, or by another - else as sure
; as @self is of it.
(define-func hedged (?said ?act ?asker)
  (bind (told-line ?act) ?told)
  (cond (case (not (is-belief ?told)) (answer-as-sure ?said (belief-certainty ?act)))
        (case (eq ?told.subject ?asker) (set-msg-rider ?said told ?told @you))
        (else (set-msg-rider ?said told ?told))))

; How many acts of ?act's run @self holds in his habit of it - the most a merged memory of it stands
; for - or 1 when he holds no habit of it.
(define-func habit-times (?act)
  (bind 1 ?most)
  (for-each ?habit (every ?habit {?act.subject ? ? /ever} (where (and (is-act ?habit) (same-run ?act ?habit))))
    (bind (times ?habit) ?times)
    (if (> ?times ?most) (then (bind ?times ?most))))
  ?most)

; The beat ?said that tells ?act among ?acts, said as its telling counts it: a run said as what kept
; going on, a stretch with its count, a stretch of a run told before said again, and as he often does
; when he holds a habit of its run.
(define-func counted (?said ?act ?acts ?progressive)
  (bind ?said ?beat)
  (bind (cond (case ?progressive (run-count ?act ?acts)) (else (stretch-count ?act ?acts))) ?run)
  (if (and ?progressive (>= ?run (k-kept-times))) (then (bind (set-msg-rider ?beat aspect iterative) ?beat)))
  (if (and (not ?progressive) (> ?run 1)) (then (bind (set-msg-rider ?beat times ?run) ?beat)))
  (if (and (not ?progressive) (not (run-first ?act ?acts))) (then (bind (set-msg-rider ?beat again @true) ?beat)))
  (bind (habit-times ?act) ?habit)
  (if (> ?habit 1) (then (bind (set-msg-rider ?beat habitual ?habit) ?beat)))
  ?beat)

; The telling of ?acts to ?asker: what was going on (?progressive) or what happened. Its beats are
; the first of each run, in the order they began, the next each time the earliest not yet told. A beat
; of what happened says when it began, unless it began when the beat before it did (ruling 18).
; When ?asker himself told him every one of them, he has nothing of his own to tell: "Only what you
; told me: that ..".
(define-func telling (?acts ?progressive ?asker)
  (bind (msg /utterable /reply []) ?told)
  (bind (formulaic /reply [] response only-told) ?only)
  (bind @nothing ?after)
  (bind 0 ?ties)
  (bind 0 ?beats)
  (bind 0 ?theirs)
  (bind @nothing ?last-clock)
  (repeat (k-told-beats)
    (bind @nothing ?next)
    (for-each ?act ?acts
      (if (and (beat-first ?act ?acts ?progressive)
               (told-later ?act ?acts ?progressive ?after ?ties ?beats)
               (cond (case (unsubstantial ?next) @true) (else (began-before ?act ?next))))
          (then (bind ?act ?next))))
    (if (unsubstantial ?next) (then (break)))
    (bind (recalled-clock /start ?next) ?clock)
    (bind (and (not ?progressive) (not (unknown ?clock)) (neq ?clock ?last-clock)) ?timed)
    (bind (flip ?timed (msg [] ?clock ?next) (msg [] ?next)) ?said)
    (bind ?clock ?last-clock)
    (bind (add-func-arg ?told (counted (hedged ?said ?next ?asker) ?next ?acts ?progressive)) ?told)
    (bind (add-func-arg ?only ?next) ?only)
    (bind (told-line ?next) ?line)
    (if (and (is-belief ?line) (eq ?line.subject ?asker)) (then (bind (+ ?theirs 1) ?theirs)))
    (bind (+ ?beats 1) ?beats)
    (bind (flip (eq (start-time ?next) ?after) (+ ?ties 1) 1) ?ties)
    (bind (start-time ?next) ?after))
  (bind (flip (= ?theirs ?beats) ?only ?told) ?said)
  (cond (case (= ?beats 0) @unknown)
        (case ?progressive (set-msg-rider ?said aspect progressive))
        (else ?said)))

; What he saw done at ?where during ?when, told to ?asker: what was going on.
(define-func seen-there (?where ?when ?asker)
  (if (unsubstantial ?where)
      (then @unknown)
      (else (telling (what-was-seen ?where ?when) @true ?asker))))

; What ?who was doing during ?when, told to ?asker: what was going on.
(define-func doing-then (?who ?when ?asker)
  (or-idle (telling (doing-during ?who ?when) @true ?asker) ?who ?when))

; What ?who did during ?when, told to ?asker: what happened, in time order.
(define-func done-then (?who ?when ?asker)
  (or-idle (telling (doing-during ?who ?when) @false ?asker) ?who ?when))

; The telling ?told of what ?who was doing during ?when, else, when he holds no act of ?who then but
; was where he saw him, that ?who did not seem to be doing much (ruling 4); else what ?who is wont
; to do then (or-habit).
(define-func or-idle (?told ?who ?when)
  (cond (case (substantial ?told) ?told)
        (case (substantial (any {?who ? ? /during ?when /at ?})) (formulaic [] response idle ?who))
        (else (or-habit ?who ?when))))

; Where ?who was during ?when as the man holds it, else what ?who is wont to do then (or-habit).
(define-func whereabouts-then (?who ?when)
  (bind (whereabouts-on ?who ?when) ?where)
  (if (substantial ?where)
      (then ?where)
      (else (or-habit ?who ?when))))

; HABIT (W1 C3) - when nothing he holds of that time answers: the places ?who frequents in the
; parts of the day ?when reaches into, the habit tally's {?who frequent <building> <part of the
; day>}, at most (k-told-habits). He does not know - or, placing himself somewhere else then, he
; was not there - but she is in the Red Lion most evenings. @unknown when no habit answers either.
(define-func or-habit (?who ?when)
  (bind (every ?habit {?who /pres frequent ? ?} (where (part-during ?habit.auxiliary ?when))) ?habits)
  (bind (whereabouts-on @self ?when) ?mine)
  (bind (substantial ?mine) ?elsewhere)
  (for-each ?habit ?habits
    (if (and ?elsewhere (spatial ?mine building ?habit.target))
        (then (bind @false ?elsewhere))))
  (bind (flip ?elsewhere wasnt-there dont-know) ?opener)
  (bind (formulaic /reply [] response habit ?opener) ?said)
  (bind 0 ?told)
  (for-each ?habit ?habits
    (if (< ?told (k-told-habits))
        (then (bind (add-func-arg ?said ?habit) ?said)
              (bind (+ ?told 1) ?told))))
  (flip (= ?told 0) @unknown ?said))

; How @self knows what he last told ?asker, asked who told him (?asked who) or how he knows (how):
; who told him the first of its beats he was told - "You did, just now", "Silas Brennan told me" - or
; that nobody did, he saw it himself. @unknown when his last line to ?asker told nothing he saw or
; heard.
(define-func told-source (?asker ?asked)
  (bind (shared-talk ?asker) ?talk)
  (bind @nothing ?last)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject @self) (eq ?line.auxiliary ?asker)
                   (or (is-telling ?line.target) (matches ?line.target (formulaic ? response only-told ?..))))
              (then (bind ?line ?last))))))
  (bind @nothing ?source)
  (if (is-belief ?last)
      (then
        (for-each ?beat (msg-sentences /whole ?last.target)
          (bind (beat-teller ?beat) ?told)
          (if (is-belief ?told)
              (then (bind ?told ?source) (break))))))
  (if (and (is-belief ?last) (matches ?last.target (formulaic ? response only-told ?..)))
      (then (bind (told-line (nth (k-formulaic-payload-field) ?last.target)) ?source)))
  (cond (case (and (is-belief ?source) (eq ?source.subject ?asker)) (told-by-you ?source ?talk ?asked))
        (case (is-belief ?source) (formulaic [] response told-by ?asked ?source.subject))
        (case (is-belief ?last) (formulaic [] response saw-it ?asked))
        (else @unknown)))

; ?asker told it him, said as the answer ?asked asks it: "You did" / "You told me", and "just now"
; when the line ?line was said in ?talk.
(define-func told-by-you (?line ?talk ?asked)
  (flip (eq (said-in ?line) ?talk)
        (formulaic [] response told-by-you ?asked just-now)
        (formulaic [] response told-by-you ?asked)))

; The line that told @self the beat ?beat, or @nothing when he saw it: its [/told <line> ..] rider.
(define-func beat-teller (?beat)
  (bind (msg-rider ?beat told) ?told)
  (flip (is-list ?told) (head ?told) ?told))

; ?msg is a telling: a sentence of it is a beat, a line of its own with its riders.
(define-func is-telling (?msg)
  (bind @false ?telling)
  (for-each ?sentence (msg-sentences /whole ?msg)
    (if (matches ?sentence (msg ?..))
        (then (bind @true ?telling) (break))))
  ?telling)
