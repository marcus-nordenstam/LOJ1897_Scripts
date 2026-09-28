; ----------------------------------------------------------------------------
; construe-speech (reflex) - the speech-act classification reflex.
;
; A SAY act record carries its utterance in the target and its addressee in the
; aux; the classification rides the msg's (msg-class <label>) arg. Reframing
; the record under the classified label with patient = the addressee is what
; lets the appraise phase construe an insult as an insult rather than a SAY.
; Runs in EVERY holder's mind (speaker's own record included - classify gates
; do not self-exclude); an unclassified SAY fails (substantial) and no-ops.
; Mirrors (and will retire) the C++ reprojection block in categorize().
; ----------------------------------------------------------------------------

(reflex {?speaker SAY ?msg ?audience /ever}:?SAY
  (msg-class-of ?msg):?class
  (when (substantial ?class))
  (effects
    (reframe ?SAY ?class ?speaker ?audience)
    ))
