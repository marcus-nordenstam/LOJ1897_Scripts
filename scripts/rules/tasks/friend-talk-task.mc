; ----------------------------------------------------------------------------
; friend-talk ?talk ?friend - the FRIEND-TALK dialogue task: in the conversation ?talk @self tells
; ?friend his news ?friend has not heard, asks what is new with him, and passes on gossip he has not
; heard, one line at a time (friend-talk-line, funcs/conversation.mc). It is spent, a success, when
; he has nothing left for ?friend and every question he asked him has its reply. Proposed by
; seek-company (drivers/seek-company-driver.mc).
; ----------------------------------------------------------------------------

(task {@self friend-talk ?talk ?friend}:?friend-talk
  (noncompete-set discourse)
  (tar @excl [k conversation] @object)
  (aux [k human] @object)
  (and
    (try
      (role ?friend {?talk participant ?friend}
        (bind (friend-talk-line ?talk ?friend) ?line)
        (when (and (substantial ?line) (none {@self tell ?line ?friend /succ})))
        (effects (maintain-proposal {@self tell ?line ?friend} /quit-trying-on-fail))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial (friend-talk-line ?talk ?friend))
                 (not (friend-awaits-reply ?talk ?friend))))
      (effects (set-outcome ?friend-talk /succ)))))
