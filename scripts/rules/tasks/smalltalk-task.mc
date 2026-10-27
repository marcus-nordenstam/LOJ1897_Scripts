; ----------------------------------------------------------------------------
; smalltalk ?talk ?partner - the SMALLTALK dialogue task: in the conversation ?talk @self remarks on
; the weather to ?partner (smalltalk-line, funcs/conversation.mc), and answers a remark of his by
; building on it with his own or, having none, by agreeing. It is spent, a success, when he has no
; remark left and every remark of ?partner's in the talk has its answer. Proposed by smalltalk-unease
; and return-smalltalk (drivers/smalltalk-driver.mc).
; ----------------------------------------------------------------------------

(task {@self smalltalk ?talk ?partner}:?smalltalk
  (tar @excl [k conversation] @object)
  (aux [k human] @object)
  (and
    (try
      (role ?partner {?partner SAY (msg ~[/msg-class smalltalk] ?..) @self /past}:?line
                     -{@self tell ? ?partner /succ /caused_by ?line}
        (bind (any {?talk participant @self}) ?part)
        (bind (smalltalk-reply ?talk) ?reply)
        (when (happened-since ?line ?part))
        (effects (maintain-proposal {@self tell ?reply ?partner} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?partner {?talk participant ?partner}
        (bind (smalltalk-line ?talk) ?remark)
        (when (and (substantial ?remark)
                   (none {@self tell ?remark ?partner /succ})
                   (not (awaits-smalltalk-answer ?talk ?partner))))
        (effects (maintain-proposal {@self tell ?remark ?partner} /quit-trying-on-fail))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial (smalltalk-line ?talk)) (not (awaits-smalltalk-answer ?talk ?partner))))
      (effects (set-outcome ?smalltalk /succ)))))
