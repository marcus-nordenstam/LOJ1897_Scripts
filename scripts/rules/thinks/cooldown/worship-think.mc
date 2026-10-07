; ----------------------------------------------------------------------------
; worship (think) - the churchgoing drives. Each raises the attend-church-service task
; (tasks/attend-church-service-task.mc), which gets him into a nave and proposes WORSHIP
; there; the drives read the {@self WORSHIP} act belief for days-since-last, so a service
; relieves them all at once.
;
;   want-worship:      a churchgoer (some politeness) overdue for a service. The pressure
;                      ramps with days since the last one, swung by politeness.
;   sunday-observance: the devout's observance, cast on the devoutness classifier: an
;                      obligation, not a passing want, so it outranks errands and leisure.
; A third drive, rehabilitation (rehabilitation-think.mc), raises the same task on a
; disreputable man's 15-day itch; the sources sum on the one proposal.
; ----------------------------------------------------------------------------

(include "../../../macros/intensity-macros.mc")

(think want-worship
  (cooldown 3 d try-until-succ)
  (role @self {@self politeness ?politeness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (when    (and (>= (days-since-last {@self WORSHIP /succ /ever}) 3)
                  (>= ?politeness 0.3)))
    (declare-utility want (* (* 500.0 (clamp (/ (- (days-since-last-float {@self WORSHIP /succ /ever}) 3.0)
                                         (- 21.0 3.0))
                                      0.0 1.0)) (clamp (+ 1.0 (delib-ctr ?politeness (k-drive-trait-swing))) 0.0 2.0)))
    (effects (maintain-proposal {@self attend-church-service}))))

(think sunday-observance
  (cooldown 3 d try-until-succ)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self devoutness [k devout]}
    (when    (>= (days-since-last {@self WORSHIP /succ /ever}) 3))
    (declare-utility obligation)
    (effects (maintain-proposal {@self attend-church-service}))))
