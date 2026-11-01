; ----------------------------------------------------------------------------
; construe-speech (reflex) - a classified line is construed as its class says.
;
; A SAY carries its line in the target and its addressee in the aux, and the line's class
; rides the msg as [/msg-class <leaf>]. Each (construed-act ..) tag of the class
; (ontology/concepts.mon) construes the SAY as that act of the speaker's against the
; addressee, so an insult is taken as a slight. Runs in every holder's mind, the speaker's
; own included; an unclassified line construes nothing.
; ----------------------------------------------------------------------------

(reflex {?speaker SAY ?msg ?audience /ever}:?SAY
  (msg-class-of ?msg):?class
  (when (substantial ?class))
  (effects
    (for-each ?construal (construals-of ?class)
      (construe ?SAY ?construal ?speaker ?audience))))
