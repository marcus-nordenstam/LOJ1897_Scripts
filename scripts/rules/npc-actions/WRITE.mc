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
; the composing + which sentences to write are the task's job. The ENVELOPE rides on
; the message as riders - (table-msg [/addressee ?name /address ?addr] ..) - and is
; stamped onto the paper here: addressee for the sorter at the door, destination for
; the mail service. Absent riders stamp nothing.
;
; WRITE_DOC WAS THIS ACT UNDER ANOTHER NAME and is gone: the .act port minted it as a
; second label because a C++ handler registered under that spelling, and an action is
; ONE label. Its presentation, its motor and its field declarations came here; its
; handler held nothing but a success return. The presented length is PROCEDURAL, as its
; `run = ?` was: the body ends the act itself on its first tick, the pen having written,
; and no clock has a say. The ten minutes is the scheduled length.
; ----------------------------------------------------------------------------

(npc-action {@self WRITE ?doc ?sentence}
  (track-skill-level [k literacy])
  (motor right-hand legs)
  (obs)
  (tar @excl)
  (aux @msg @excl)
  (duration
    (cond (case (presented-lod) procedural)
          (else (seconds 10 min))))
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))
  (effects
    (check (spatial ?doc co-located @self /env))
    ; Whatever the message claims about who wrote it, the hand is the writer's own.
    (set-msg-rider ?sentence handwriting (attr @self handwriting)): ?penned
    (tolerate (table-rows ?sentence): ?rows)
    (cond
      (case (substantial ?rows)
        (if (nothing (attr ?doc writing))
            (then (table-init ?doc field value)))
        (for-each ?entry ?rows
          (table-add ?doc field (head ?entry) value (nth 1 ?entry)))
        (table-add ?doc field handwriting value (attr @self handwriting)))
      (case (nothing (attr ?doc writing))
        (set-writing ?doc ?penned))
      (else
        (set-writing ?doc (add-func-arg (attr ?doc writing) ?penned))))
    (tolerate (msg-rider ?sentence addressee): ?to)
    (if (substantial ?to) (then (set-attr ?doc addressee ?to)))
    (tolerate (msg-rider ?sentence address): ?dest)
    (if (substantial ?dest) (then (set-attr ?doc destination ?dest)))
    (set-outcome {@self WRITE ?doc ?sentence} /succ)))
