; ----------------------------------------------------------------------------
; write ?doc ?sentence - THE one document-writing action: inscribe ?sentence into
; ?doc's writing, APPENDING to whatever is already there. Pen changes paper, one
; sentence at a time. Composed entirely from general funcs: read the current
; writing ((attr ?doc writing)); if blank, mint (msg ?sentence); else append the
; sentence as a new arg of the existing (msg ..) with add-func-arg. Reading (READ)
; adopts every sentence back. A doc is created first (CREATE_ENTITY), then WRITTEN;
; the composing + which sentences to write are the task's job.
; ----------------------------------------------------------------------------

(npc-action {@self WRITE ?doc ?sentence}
  (duration 10)
  (effects
    (if (nothing (attr ?doc writing))
        (then (set-writing ?doc (written-msg ?sentence)))
        (else (set-writing ?doc (add-func-arg (attr ?doc writing) ?sentence))))
    (set-outcome {@self WRITE ?doc ?sentence} succ)))
