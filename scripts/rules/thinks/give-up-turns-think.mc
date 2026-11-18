; give-up-turns - a man who holds a turn with no line being said and none he means to say gives
; every turn up: the turn was handed to him after whatever wanted the line said let it go.

(think give-up-turns
  (when (and (holds-turn ?) (none {@self SAY ? ?}) (none {@self intent {@self SAY ? ?}})))
  (effects (turn-release ?)))
