; ----------------------------------------------------------------------------
; sponsor ?protege - the patron tells the protege, to his face, that he backs him: a state
; ({?protege backed-by @self}), which the protege adopts as told and business-founding reads
; in his own mind. Told, the patron holds it too, and that belief retires the patronage
; intender's protege.
; ----------------------------------------------------------------------------

(task {@self sponsor ?protege}:?sponsor
  (tar [k human] @object)
  (sequence
    (stage
      (effects
        (if -{@self tell ? ?protege /succ /caused_by ?sponsor}
            (then (maintain-proposal {@self tell (utterable-msg [] {?protege backed-by @self}) ?protege})))))
    (stage
      (effects
        (begin-belief {?protege backed-by @self})
        (set-outcome ?sponsor /succ)))))
