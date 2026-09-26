; ----------------------------------------------------------------------------
; ASSIGN-DEED ?building ?assignee - make the deed of a building @self owns over to
; ?assignee (a person, or an org's articles) and give up his own claim to it.
; ----------------------------------------------------------------------------

(npc-action {@self ASSIGN-DEED ?building ?assignee}:?ad-rel
  (tar [k building] @object)
  (aux @object)
  (motor body legs)
  (duration (seconds 30 min))
  (effects
    (for-each ?deed (env-entities [k title-deed])
      (do
        (table-match (attr ?deed writing) owner ?o building ?b)
        (if (and (= ?b ?building) (= ?o @self))
          (then
            (table-set ?deed owner ?assignee)
            (break)))))
    (end-belief {@self own ?building})
    (set-outcome ?ad-rel /succ)))
