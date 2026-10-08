; ----------------------------------------------------------------------------
; open-barrier ?barrier - open a shut door or window: walk up to it, then OPEN it. Succeeds when
; the OPEN it caused does, and fails when that OPEN fails - the barrier was locked after all.
; go proposes it for the barrier its walk was barred by, only while @self believes it shut and
; not locked.
; ----------------------------------------------------------------------------

(task {@self open-barrier ?barrier}:?open-barrier
  (tar @excl [k door|window] @object)
  (preemptive-or
    (try
      (when {@self OPEN ?barrier /succ /caused_by ?open-barrier})
      (effects (set-outcome ?open-barrier /succ)))
    (try
      (when {@self OPEN ?barrier /fail /caused_by ?open-barrier})
      (effects (set-outcome ?open-barrier /fail)))
    (try
      (when (spatial ?barrier co-located @self))
      (effects (maintain-proposal {@self OPEN ?barrier})))
    (try
      (when (poll (maintain-claim-spot @self [/near ?barrier] [/at_or_near @self]): ?spot))
      (effects
        (check (is-spot ?spot))
        (maintain-proposal {@self go ?spot})))))
