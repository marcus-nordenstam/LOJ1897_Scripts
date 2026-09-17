; ----------------------------------------------------------------------------
; idle (npc-action) - the ABSENCE of an action, made into one.
;
; Nothing proposes this, because being idle IS having nothing proposed. When a
; deliberation leaves the body motor unclaimed the engine selects IDLE itself -
; the one act it names, and it names it by reading back whichever label carries
; (idle-action) rather than by spelling IDLE in C++.
;
; (idle-action) is not a tie-break. An idle act does not compare utility at all:
; it loses to ANY act that is not idle, including one bidding zero. DWELL is the
; opposite case and must not carry it - staying at your post between duties is
; PURPOSEFUL, and it inherits the duty's utility, which is why a man does not
; wander off to play billiards halfway through his shift.
;
; The TARGET is the motor being idled, so {@self IDLE body _} and {@self IDLE
; right-hand _} are distinct acts: a man can be walking nowhere and holding nothing
; at the same time, and each motor answers for itself. The block runs its span and
; ends; any admission worth more than nothing wakes the actor before then.
; ----------------------------------------------------------------------------

(npc-action {@self IDLE ?motor}
  (idle-action)
  (duration 180)
  (effects (set-outcome {@self IDLE ?motor} /succ)))
