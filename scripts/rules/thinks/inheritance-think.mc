; The preferred heir: a living relative the testator knows, ranked spouse > child
; > sibling (a choice, not a primogeniture age-law - within a tier the select's
; first witness binds one). No candidate -> no proposal -> no will.
; A grown man's standing duty to leave his estate to his closest kin: his spouse, else a
; child, else a sibling.
(think will-duty
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
    (role ?heir {?heir isa [k human], condition [k alive]}
      {@self spouse|child|sibling ?heir}
      (select (score (+ (* 4 (count (every {@self spouse  ?heir})))
                        (* 2 (count (every {@self child   ?heir})))
                        (count       (every {@self sibling ?heir})))))
      (effects (maintain-belief {@self duty-to ?heir write-will})))))
