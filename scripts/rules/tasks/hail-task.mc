; ----------------------------------------------------------------------------
; hail ?partner - @self opens a conversation with ?partner: he goes to stand before him, posts
; his (conversing ..) naming him and calls out the opening (funcs/conversation.mc). It is
; PREPARATION - an open conversation is what converse assumes - so only a driver proposes it.
; Taken up when ?partner's own (conversing ..) names him - also when that is what ends it, its
; proposer having stopped wanting it the instant it was taken up; turned down when ?partner
; clears his. Ended any other way before it is taken up, he withdraws the hail.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (tar @excl [k human] @object)
  (preparatory)
  (init
    (check (is-a ?partner [k human]))
    (bb-public-write @self conversing ?partner))
  (cease
    (if (conversing-with ?partner @self)
        (then (set-outcome ?hail /succ))
        (else (end-conversation ?partner))))
  (and
    (try
      (when (not (standing-before ?partner)))
      (effects (maintain-proposal {@self go-to ?partner})))
    (try
      (when (and (standing-before ?partner)
                 (not (conversing-with ?partner @self))
                 -{@self tell (formulaic ? opening ?) ?partner /past /caused_by ?hail}))
      (effects (maintain-proposal {@self tell (formulaic [] opening greeting) ?partner})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (conversing-with ?partner @self))
      (effects (set-outcome ?hail /succ)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (not (conversing-with @self ?partner)))
      (effects (set-outcome ?hail /fail)))
    (try
      (when {@self go-to ?partner /fail /caused_by ?hail})
      (effects (set-outcome ?hail /fail)))))
