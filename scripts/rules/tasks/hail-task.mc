; ----------------------------------------------------------------------------
; hail ?partner - @self opens a conversation with ?partner: he goes to stand before him, joins the
; conversation ?partner is in or opens a new one (funcs/conversation.mc), and calls out the
; opening. It is PREPARATION - an open conversation is what converse assumes - so only a driver
; proposes it. Taken up when ?partner's own (conversing ..) names the same conversation - also
; when that is what ends it, its proposer having stopped wanting it the instant it was taken up;
; turned down when ?partner refuses or rebuffs him. Ended any other way before it is taken up, he
; leaves the conversation he opened.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (tar @excl [k human] @object)
  (preparatory)
  (init
    (check (is-a ?partner [k human]))
    (bind (conversation-of ?partner) ?theirs)
    (if (substantial ?theirs)
        (then (join-conversation ?theirs))
        (else (open-conversation))))
  (cease
    (if (conversing-with ?partner @self)
        (then (set-outcome ?hail /succ))
        (else (leave-conversation))))
  (and
    (try
      (when (not (standing-before ?partner)))
      (effects (maintain-proposal {@self go-to ?partner})))
    (try
      (when (and (standing-before ?partner)
                 (not (conversing-with ?partner @self))
                 -{@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}))
      (effects (maintain-proposal {@self tell (formulaic [] opening-phrase greeting) ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (conversing-with ?partner @self))
      (effects (set-outcome ?hail /succ)))
    (try
      (role ?partner {?partner SAY ? @self /past}
                     (or {?partner SAY (formulaic ? refusal ?..) @self /during ?hail}
                         {?partner SAY (formulaic ? rebuff) @self /during ?hail})
        (effects (set-outcome ?hail /fail))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (unsubstantial (conversation-of @self)))
      (effects (set-outcome ?hail /fail)))
    (try
      (when {@self go-to ?partner /fail /caused_by ?hail})
      (effects (set-outcome ?hail /fail)))))
