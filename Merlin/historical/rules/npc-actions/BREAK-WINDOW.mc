; ----------------------------------------------------------------------------
; BREAK-WINDOW ?win - smash a window: mark it broken and ajar (a shattered window is a
; permanent passable gap). Like FORCE-ENTRY it only opens the breach; the enter chain's
; WALK-in step carries the actor through.
; ----------------------------------------------------------------------------

(npc-action {@self BREAK-WINDOW ?win}:?bw-rel
  (track-skill-level [k illicit])
  (tar object) (duration 1)
  (effects
    (check (spatial ?win co-located @self))
    (set-attr ?win integrity [k broken])
    (set-attr ?win opening-status [k ajar])
    (set-outcome ?bw-rel /succ)))
