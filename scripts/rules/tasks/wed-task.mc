; ----------------------------------------------------------------------------
; wed ?partner - speak the vow to the betrothed at their wedding: the one physical act - speech -
; by which the marriage is made ({@self spouse ?partner} said to him). The vower holds it from
; the moment he has said it; the partner HEARS and adopts it (spouse-reciprocate,
; thinks/attend-think.mc), no fiat cross-mind write. The wedding is the couple's own - the one
; @self organizes, or the one ?partner invited him to - and the task gets him to its venue, a
; building or a unit, and has him speak there.
; ----------------------------------------------------------------------------

(include "../../macros/occasion-macros.mc")

(task {@self wed ?partner}:?wed
  (noncompete-set occasion)
  (tar [k human] @object)
  (role ?occ [k wedding] {?occ hours ?start ?end} {?occ venue ?venue}
             (or {@self organize ?occ} {?partner invite @self ?occ})
             (select (policy first-match))
    (and
      (try
        (effects (set-occasion-alarm ?start)))
      (try
        (role @self {@self fiancee ?partner} -{@self spouse ?}
                    (within-place @self ?venue)
                    -{@self tell ? ?partner /succ /caused_by ?wed}
          (when (hours (- ?start (attend-prep-lead)) ?end))
          (effects (maintain-proposal {@self tell (msg /utterable [] {@self spouse ?partner}) ?partner}))))
      (try
        (role @self {@self fiancee ?partner} -{@self spouse ?}
                    (not (within-place @self ?venue))
          (when (hours (- ?start (attend-prep-lead)) ?end))
          (effects (maintain-proposal {@self enter-building ?venue}))))
      (try
        (role @self {@self tell ? ?partner /succ /caused_by ?wed}
                    -{@self spouse ?}
          (effects (begin-belief {@self spouse ?partner}))))
      (try
        (role @self {@self spouse ?partner}
          (effects (set-outcome ?wed /succ)))))))
