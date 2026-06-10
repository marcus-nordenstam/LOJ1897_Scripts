; ----------------------------------------------------------------------------
; rehabilitation (Phase 9.3). An NPC with a poor respectability_situation
; (disreputable) gets an elevated chance to perform a positive behaviour -
; here, churchgoing - which the F3 piety classifier reads and which the
; respectability classifier in turn fuses into the score. Combined with the
; classification tables' time-decay (Phase 8's act-record ageing), the
; situation can recover slowly over several years.
;
; Why disreputable not scandalous: the scandalous NPC is already ostracised
; (the social door is shut) and a single church visit cannot lift them back
; to respectable in one pass. The disreputable can rehabilitate; the
; scandalous needs a longer, multi-year recovery the time-decay handles.
;
; Schedule: annually april (the existing churchgoing event also runs in
; april; rehabilitation runs alongside as a second, situation-conditional
; pass for the disreputable subset).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event rehabilitation
  (nl         "?npc seeks rehabilitation")
  (kind       _rehabilitation)
  (schedule   (annually april))
  (rng-stream behaviour)

  (roles
    ;; A disreputable adult with a personality lift toward conformity
    ;; (politeness) tries the church door. The chance is well above the
    ;; baseline churchgoing rate so the situation has a real shot at climbing.
    (role ?npc (template old_human)
               (= (situation ?self repute) disreputable)
               (chance (* 0.6 (+ 0.5 (attr ?self politeness))))))

  (effects
    (go-to-church ?npc)
    (log _rehabilitation ?npc)))
