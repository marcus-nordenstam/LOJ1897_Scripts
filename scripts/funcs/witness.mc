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

; TELLING - what he saw done, as a line of beats (W1 rulings 15-20): one beat for each run of one
; act - the same actor doing the same thing to the same kind of thing - the first of the run, in the
; order they began, at most (k-told-beats). Each beat is a line of its own, hedged by its own riders:
; told when a line told it him ([/told <the line>]), else as sure as he is of it. A line that tells
; what was going on is said progressive ([/aspect progressive]); one that tells what happened is
; said simple, a beat in time order after the one before. @unknown when he holds no act to tell.

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

; How many acts that began first of their runs, at the instant ?act began, come before ?act in ?acts.
(define-func tie-index (?act ?acts)
  (bind 0 ?index)
  (for-each ?other ?acts
    (cond (case (eq ?other ?act) (break))
          (case (and (eq (start-time ?other) (start-time ?act)) (run-first ?other ?acts))
                (bind (+ ?index 1) ?index))))
  ?index)

; ?act is told after the ?beats told so far, the last of them begun at ?after, the ?ties-th of
; those begun then.
(define-func told-later (?act ?acts ?after ?ties ?beats)
  (bind (start-time ?act) ?began)
  (cond (case (= ?beats 0) @true)
        (case (eq ?began ?after) (>= (tie-index ?act ?acts) ?ties))
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

; The beat ?said that tells ?act, hedged: told, else as sure as @self is of it.
(define-func hedged (?said ?act)
  (bind (told-line ?act) ?told)
  (flip (is-belief ?told)
        (set-msg-rider ?said told ?told)
        (answer-as-sure ?said (belief-certainty ?act))))

; The telling of ?acts: what was going on (?progressive) or what happened. Its beats are the first of
; each run, in the order they began, the next each time the earliest not yet told.
(define-func telling (?acts ?progressive)
  (bind (msg /utterable /reply []) ?told)
  (bind @nothing ?after)
  (bind 0 ?ties)
  (bind 0 ?beats)
  (repeat (k-told-beats)
    (bind @nothing ?next)
    (for-each ?act ?acts
      (if (and (run-first ?act ?acts)
               (told-later ?act ?acts ?after ?ties ?beats)
               (or (unsubstantial ?next) (began-before ?act ?next)))
          (then (bind ?act ?next))))
    (if (unsubstantial ?next) (then (break)))
    (bind (msg [] ?next) ?said)
    (bind (add-func-arg ?told (hedged ?said ?next)) ?told)
    (bind (+ ?beats 1) ?beats)
    (bind (flip (eq (start-time ?next) ?after) (+ ?ties 1) 1) ?ties)
    (bind (start-time ?next) ?after))
  (cond (case (= ?beats 0) @unknown)
        (case ?progressive (set-msg-rider ?told aspect progressive))
        (else ?told)))

; What he saw done at ?where during ?when: what was going on.
(define-func seen-there (?where ?when)
  (if (unsubstantial ?where)
      (then @unknown)
      (else (telling (what-was-seen ?where ?when) @true))))

; What ?who was doing during ?when: what was going on.
(define-func doing-then (?who ?when)
  (telling (doing-during ?who ?when) @true))

; What ?who did during ?when: what happened, in time order.
(define-func done-then (?who ?when)
  (telling (doing-during ?who ?when) @false))

; How @self knows what he last told ?asker: the man whose line told him its first beat that he was
; told, "Mary Le Feuvre told me", or that he saw it himself. @unknown when his last line to ?asker
; told nothing he saw or heard.
(define-func told-source (?asker)
  (bind (shared-talk ?asker) ?talk)
  (bind @nothing ?last)
  (if (substantial ?talk)
      (then
        (for-each ?line (bb-public-read-keys ?talk bbk-line)
          (if (and (eq ?line.subject @self) (eq ?line.auxiliary ?asker) (substantial (told-beats ?line.target)))
              (then (bind ?line ?last))))))
  (bind @nothing ?source)
  (if (is-belief ?last)
      (then
        (for-each ?beat (told-beats ?last.target)
          (bind (msg-rider ?beat told) ?told)
          (if (is-belief ?told)
              (then (bind ?told ?source) (break))))))
  (cond (case (is-belief ?source) (msg /utterable /reply [] ?source))
        (case (is-belief ?last) (formulaic [] response saw-it))
        (else @unknown)))

; The beats of the telling ?msg: its sentences that are lines of their own, empty for a plain line.
(define-func told-beats (?msg)
  (every ?beat (msg-sentences ?msg) (where (matches ?beat (msg ?..)))))
