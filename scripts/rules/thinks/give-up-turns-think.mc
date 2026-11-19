; give-up-turns - a man who holds a talk's turn with no line being said and none he means to say in
; that talk gives it up: the turn was handed to him after whatever wanted the line said let it go. A
; line he means for someone elsewhere keeps no turn here.

(think give-up-turns
  (role ?board (bb-public-every ?board turn @self)
    (when (and (none {@self SAY ? ?}) (not (line-waits-on ?board))))
    (effects (turn-release ?board))))
