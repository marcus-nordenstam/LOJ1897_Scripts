; ----------------------------------------------------------------------------
; know-own-writing - a man who has written a document knows it as its reader would: signed,
; addressed and dated as he wrote it (funcs/documents.mc), so he can say which letter he means. His
; WRITE memory, and only it, says he wrote it: the signature may be an alias.
; ----------------------------------------------------------------------------

(think know-own-writing
  (belief {@self WRITE ?doc ?sentence /succ}:?WRITE
          -{?doc write-date ?}
    (effects (learn-envelope ?doc ?sentence (time date)))))
