; ----------------------------------------------------------------------------
; read_will - eyes on the testament: adopt its written bequest into @self's mind.
; The writing codec's adopt seam is the sanctioned cross-mind write-through-paper
; (the written twin of hearing speech). A dedicated act (not the generic READ,
; which only adopts [k letter] writings) so a will's bequest is learned on sight
; of the page. If the will names @self, @self comes away holding {@self inherit
; <pile>} (the descriptor resolved to the concrete pile); if it names another, the
; adopted belief is about them.
; ----------------------------------------------------------------------------

(npc-action {@self READ_WILL ?will}
  (duration 10)
  (effects
    (adopt-msg (attr ?will writing))
    (set-outcome {@self READ_WILL ?will} succ)))
