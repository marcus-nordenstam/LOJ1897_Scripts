; ----------------------------------------------------------------------------
; hire-assassin ?victim - a killing means pursue-kill (thinks/hot/kill-think.mc) proposes to
; a man with the fee in his carrying-cash-pile. It is a SAY: reach a known third party and solicit him to
; kill the victim. The solicitation is the performance, so it ends the intent; the hired man
; carrying it out is conspiracy-adoption's (thinks/cooldown/conspiracy-adoption-think.mc).
;
; TODO - @self solicits ANYONE it personally knows, with no belief about whether
; they would ever take the work. The knowledge half is missing on both sides:
;   (a) PREFER a believed hireling. Once classify_others_for_hire exists (see the
;       TODOs in thinks/classify/README.md) the ?killer cast should score
;       {?killer prototype for-hire} above a bare acquaintance, so the solicitation
;       goes to someone @self has reason to think will accept.
;   (b) ACQUIRE the belief when @self holds none - a (try) rung ABOVE the reach /
;       solicit rungs. Two legal channels, both already modelled: approach a known
;       {?fixer prototype go-between} and ask for a name, or treat the solicitation
;       itself as the probe (you ask, and the answer teaches you). Either way the
;       task that needs the knowledge is the task that goes and gets it.
; Until then this chain works, but blindly - it asks whoever it happens to know.
; ----------------------------------------------------------------------------


(task {@self hire-assassin ?victim}:?hire-assassin
  (tar [k human] @object)
  (construed-act harm-act) (theme violent-to) (contradicts life)
  (facets reportable_crime blackmailable)
  (role ?killer {?killer isa [k human], condition [k alive]}
                {@self (closeness-labels acquaintance) ?killer /ever}
                (!= ?killer ?victim)
    (and
      ; SOLICIT: put the contract to the prospective killer (the words are the deed).
      (try
        (when (or (spatial ?killer co-located @self) (spatial ?killer space)))
        (declare-utility survival always-pick)
        (effects (maintain-proposal {@self tell (utterable-msg [] {@self intent {@self kill ?victim}} {?killer kill ?victim}) ?killer})))

      ; CONCLUDE once the solicitation has been spoken.
      (try
        (when {@self tell ? ?killer /succ /caused_by ?hire-assassin})
        (effects (set-outcome ?hire-assassin /succ))))))
