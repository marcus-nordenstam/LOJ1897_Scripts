; ----------------------------------------------------------------------------
; read - THE one document-reading action: adopt a document's writing (its composed
; message) into @self's mind. Works for ANY document - a letter, a will, a listing,
; a deed, a register. The writing codec's adopt seam is the sanctioned cross-mind
; write-through-paper (the written twin of hearing speech): @self comes away holding
; whatever beliefs the page asserts. Dumb and general - it ONLY reads. Getting the
; document into reach, and putting it down / re-filing it afterwards, are the
; consuming task's job (via get / DROP / stack_browse), never bundled in here.
; ----------------------------------------------------------------------------

(npc-action {@self READ ?doc}
  (track-skill-level [k literacy])
  (duration 10)
  (effects
    (adopt-msg (attr ?doc writing))
    (set-outcome {@self READ ?doc} /succ)))
