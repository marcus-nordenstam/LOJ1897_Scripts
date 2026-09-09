; ----------------------------------------------------------------------------
; write ?doc ?sentence - THE one document-writing action: inscribe ?sentence into
; ?doc's writing, APPENDING to whatever is already there. Pen changes paper, one
; sentence at a time. A FORM is written the same way: ?sentence is then a
; (table-msg [[field value] ..]) - the wrapper is what makes a table legal to carry
; on an act, since a bare LIST may never sit in a belief's subject / target / aux,
; exactly as (msg ..) wraps a clause. The paper's writing is a two-column TABLE
; (field, value) that any reader looks up by field. Composed entirely from general funcs: read the current
; writing ((attr ?doc writing)); if blank, mint (msg ?sentence); else append the
; sentence as a new arg of the existing (msg ..) with add-func-arg. Reading (READ)
; adopts every sentence back. A doc is created first (CREATE-ENTITY), then WRITTEN;
; the composing + which sentences to write are the task's job.
; ----------------------------------------------------------------------------

(npc-action {@self WRITE ?doc ?sentence}
  (track-skill-level [k literacy])
  (duration 10)
  (effects
    (check (spatial ?doc co-located @self /env))
    (tolerate (table-rows ?sentence): ?rows)
    (if (substantial ?rows)
        (then
          (if (nothing (attr ?doc writing))
              (then (table-init ?doc field value)))
          (for-each ?entry ?rows
            (table-add ?doc field (head ?entry) value (nth 1 ?entry))))
        (else
          (if (nothing (attr ?doc writing))
              (then (set-writing ?doc ?sentence))
              (else (set-writing ?doc (add-func-arg (attr ?doc writing) ?sentence))))))
    (set-outcome {@self WRITE ?doc ?sentence} /succ)))
