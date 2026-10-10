; ----------------------------------------------------------------------------
; write ?doc ?sentence - THE one document-writing action: inscribe ?sentence into
; ?doc's writing, APPENDING to whatever is already there. Pen changes paper, one
; sentence at a time. A FORM is written the same way: ?sentence is then a
; (table-msg <form> [[field value] ..]) - the wrapper is what makes a table legal to carry
; on an act, since a bare LIST may never sit in a belief's subject / target / aux,
; exactly as (msg ..) wraps a clause. A form fills a BLANK paper, which then holds the
; (table-msg ..) itself, riders and all; a reader reads it with (form-match ..).
; Composed entirely from general funcs: read the current writing ((attr ?doc writing));
; if blank, write the penned message; else append the sentence as a new arg of the
; existing (msg ..) with add-func-arg. Reading (READ) adopts every sentence back. A doc is created first (CREATE-ENTITY), then WRITTEN;
; the composing + which sentences to write are the task's job. The ENVELOPE rides on
; the message as riders - (table-msg [/addressee ?name /address ?addr] <form> ..) - and is
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

(action {@self WRITE ?doc ?sentence}:?WRITE
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
    (tolerate (spatial @self can-reach ?doc /env)): ?at-hand
    (if (not ?at-hand)
      (then
        (tolerate (spatial @self space /env)): ?self-space-env
        (tolerate (spatial ?doc space /env)): ?doc-space-env
        (tolerate (spatial @self space)): ?self-space-mind
        (tolerate (spatial ?doc space)): ?doc-space-mind
        (tolerate (spatial ?doc held-by /env)): ?holder-env
        (tolerate (spatial ?doc held-by)): ?holder-mind
        (tolerate (spatial @self can-reach ?doc)): ?co-mind
        (tolerate (distance (spatial ?doc bounds /env) (spatial @self bounds /env))): ?gap-env
        (tolerate (distance ?doc @self)): ?gap-mind
        (tolerate (presented-lod)): ?presented
        (debug-print "WRITE-PROBE @self doc=?doc presented=?presented")
        (debug-print "WRITE-PROBE env: self=?self-space-env doc=?doc-space-env holder=?holder-env gap=?gap-env")
        (debug-print "WRITE-PROBE mind: self=?self-space-mind doc=?doc-space-mind holder=?holder-mind gap=?gap-mind co=?co-mind")))
    (check ?at-hand)
    ; Whatever the message claims about who wrote it, the hand is the writer's own, and it is
    ; the hand he has TODAY: a letter from his boyhood keeps his boyhood hand.
    (set-msg-rider ?sentence handwriting
      (attr @self handwriting)
      (attr @self hand-slant) (attr @self hand-weight)
      (attr @self hand-letter-spacing) (attr @self hand-line-spacing)
      (attr @self hand-regularity)): ?penned
    (cond
      (case (nothing (attr ?doc writing))
        (set-writing ?doc ?penned))
      (else
        (check (unsubstantial (table-rows ?sentence)))
        (set-writing ?doc (add-func-arg (attr ?doc writing) ?penned))))
    (tolerate (msg-rider ?sentence addressee): ?to)
    (if (substantial ?to) (then (set-attr ?doc addressee ?to)))
    (tolerate (msg-rider ?sentence address): ?dest)
    (if (substantial ?dest) (then (set-attr ?doc destination ?dest)))
    (set-outcome ?WRITE /succ)))
