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
