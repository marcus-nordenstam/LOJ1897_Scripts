; ----------------------------------------------------------------------------
; read - THE document-reading action: eyes on paper for the duration, nothing
; else. What the reader LEARNS is minted in think rules gated on this act's
; outcome (advert_learn / register_learn in job_search_think.hs - the isim
; post-action pattern). The one in-act channel is (read-writing ?doc) for a
; letter: the writing codec adopts the AUTHOR's composed message into the
; reader - the sanctioned cross-mind write-through-paper, the written twin of
; hearing speech.
; ----------------------------------------------------------------------------

(npc-action {@self read ?doc}
  (duration 10)
  (effects
    (if (is-a ?doc [k letter])
        (then (read-writing ?doc)))
    (set-outcome {@self read ?doc} succ)))
