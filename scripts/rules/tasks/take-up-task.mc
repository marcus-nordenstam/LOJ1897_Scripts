; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the hail ?partner called to him from outside any talk @self is
; in: the two of them are in one talk (take-up-talk, funcs/talk.mc) - ?partner's when he is in one,
; else @self's own, else the one ?partner opened to call him in, else a new one - and his answer is
; on ?partner's board (take-up-into). Presented he first gives the response the opening calls for.
; Entering a talk is its own category, enter-talk, within the talk the two would talk in
; (talk-between): a talk of his hosts it only when it is that one, so taking up a hail into another
; talk competes with his part in his own. It is PREPARATION for his part in the talk, proposed by
; engage-hail (drivers/answer-hail-driver.mc). Until he has taken ?partner in the hail still stands,
; so a man who finds something keener first declines it instead (decline-hail). Once in it, his part
; there is what he says and how he leaves (drivers/stay-in-talk-driver.mc). ?partner's hail ended by
; then leaves nothing to take up, and ?partner's talk full by then has no seat for him: either fails
; the take-up.
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (belief-timeout 15 min)
  (category enter-talk (scope (talk-between ?partner)))
  (tar @excl [k human] @object)
  (preparatory)
  (and
    (sequence
      (lod presented)
      (stage
        (when (is-belief (opening-from ?partner)))
        (bind (opening-from ?partner) ?opening)
        (bind (hail-response ?opening.target) ?response)
        (effects (maintain-proposal {@self tell ?response ?partner} /caused_by ?opening)))
      (stage
        (effects
          (if (take-up-into ?partner ?take-up)
              (then (set-outcome ?take-up /succ))
              (else (set-outcome ?take-up /fail))))))
    (sequence
      (lod unpresented)
      (stage
        (effects
          (if (take-up-into ?partner ?take-up)
              (then (set-outcome ?take-up /succ))
              (else (set-outcome ?take-up /fail))))))))
