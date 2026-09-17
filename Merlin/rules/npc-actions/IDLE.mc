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

; NO DURATION, and no outcome of its own. Idling has no length - it lasts until something
; worth doing displaces it - so nothing schedules its conclusion and the motor simply
; carries it until a real act takes the motor. The actor still re-deliberates every
; k_idle_minutes on the engine's own heartbeat, which is also where the body advances.
(npc-action {@self IDLE ?motor}
  (idle-action))
