; ----------------------------------------------------------------------------
; dwell (npc-action) - THE shared stay-put primitive: be at ?place for ?dur
; minutes, for whatever reason the proposing think holds (an occasion window,
; idling at home, manning a post between duties, waiting on a meal). The
; duration is the PROPOSER's decision and rides the aux - the action reads
; nothing. A maintaining think keeps the proposal alive across completions
; (retire_running_node), so the stay resumes quantum-to-quantum until the
; think's gate falls - and every completion is a preemption point where a
; higher bid takes over.
; ----------------------------------------------------------------------------

(npc-action {@self dwell ?place ?dur}
  (duration ?dur)
  (effects (set-outcome {@self dwell ?place ?dur} succ)))
