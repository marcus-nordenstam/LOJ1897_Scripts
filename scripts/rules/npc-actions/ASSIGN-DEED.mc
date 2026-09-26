; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;; ----------------------------------------------------------------------------
;; ASSIGN-DEED ?building ?assignee - make the deed of a building @self owns over to
;; ?assignee (a person, or an org's articles) and give up his own claim to it.
;; ----------------------------------------------------------------------------

;(npc-action {@self ASSIGN-DEED ?building ?assignee}:?ad-rel
;  (tar [k building] @object)
;  (aux @object)
;  (motor body legs)
;  (duration (seconds 30 min))
;  (effects
;    (title-deed-of ?building): ?deed
;    (if (table-match (attr ?deed writing) owner (name @self))
;      (then (table-set ?deed owner (name ?assignee))))
;    (end-belief {@self own ?building})
;    (set-outcome ?ad-rel /succ)))
