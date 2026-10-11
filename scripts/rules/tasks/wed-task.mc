; ----------------------------------------------------------------------------
; wed ?partner - speak the vow to the betrothed at the wedding: the one physical act - speech -
; by which the marriage is made ({@self spouse ?partner} said to him); the partner HEARS and
; adopts it, no fiat cross-mind write. The wedding is the one this principal organizes or was
; invited to, on its day; the task gets him to its venue and has him speak there. Whoever vows
; first marries, the other hears and reciprocates (spouse-reciprocate, thinks/attend-think.mc).
; ----------------------------------------------------------------------------

(include "../../macros/occasion-macros.mc")

(task {@self wed ?partner}:?wed
  (tar [k human] @object)
  (role ?occ [k wedding] {?occ hours ?start ?end} {?occ venue ?venue}
             (or {@self organize ?occ} {? invite @self ?occ})
             (select (policy first-match))
    (and
      (try
        (effects (set-occasion-alarm ?start)))
      (try
        (role @self {@self fiancee ?partner} (none {@self spouse @something})
                    (spatial @self building ?venue)
          (when (and (hours (- ?start (attend-prep-lead)) ?end)
                     -{@self tell (msg ? {@self spouse ?partner}) ?partner /succ}))
          (effects (maintain-proposal {@self tell (utterable-msg [] {@self spouse ?partner}) ?partner}))))
      (try
        (role @self {@self fiancee ?partner} (none {@self spouse @something})
                    (not (spatial @self building ?venue))
          (when (hours (- ?start (attend-prep-lead)) ?end))
          (effects (maintain-proposal {@self go-to ?venue}))))
      (try
        (when {@self spouse ?partner})
        (effects (set-outcome ?wed /succ))))))
