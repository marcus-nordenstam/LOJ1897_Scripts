; ----------------------------------------------------------------------------
; find-out ?fact - @self learns the fact clause ?fact ({?home supper-hour ?}) by whatever means he
; has. Asking: a man he takes to be able to tell him (could-know: the fact is about him, or he
; fits its author as the rulebook describes him) and does not take not to know it is hailed - the
; hail's opening takes @self to him; once they talk, the question is the conversation's to put
; (drivers/ask-wonder-driver.mc). A man who turns the hail down is not hailed again, and "I
; don't know" rules him out; the next is sought. It is done when he knows the fact.
; Proposed by want-to-know (drivers/want-to-know-driver.mc).
; ----------------------------------------------------------------------------

(task {@self find-out ?fact}:?find-out
  (tar @pattern)
  (lint-waive task-no-preparation)
  (success-cond (substantial (any ?fact)))
  (role ?who {?who isa [k human]}
             (neq ?who @self)
    (when (and (askable ?who ?fact) (not (engaged-with ?who))))
    (try
      (effects (maintain-proposal {@self hail ?who} /quit-trying-on-fail)))))
