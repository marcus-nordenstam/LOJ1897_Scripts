; ----------------------------------------------------------------------------
; ADDRESS ?doc ?address - the one dumb act of writing an ADDRESS on a document's envelope:
; where the mail service carries it. Which address (the org's premises, a person's home)
; is what the proposing task BELIEVES; the act stamps the value it is handed.
; ----------------------------------------------------------------------------

(npc-action {@self ADDRESS ?doc ?address}
  (duration 1)
  (effects
    (set-attr ?doc address ?address)
    (set-outcome {@self ADDRESS ?doc ?address} /succ)))
