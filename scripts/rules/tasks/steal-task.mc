; ----------------------------------------------------------------------------
; steal ?kind - take an instance of ?kind WITHOUT paying, when unwatched. The crime
; twin of buy: same source-walk (to a shop that stocks the kind), but the grip is
; gated on (nobody-watching) - a snatch waits for the shelf to be unobserved - and no
; coin changes hands. The wronged party is the source's proprietor; the take concludes
; the theft and lands the crime row. The ended {@self steal ?kind} belief IS the
; deed memory (act/state doctrine) - no fiat record. A shop is known: the acquire driver
; searches for one first.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(task {@self steal ?kind}:?steal
  (track-skill-level [k illicit])
  (tar ?)
  (construed-act appropriation-act wrong-act) (theme thief-to) (contradicts property)
  (facets reportable_crime blackmailable)
  (and
    ; not at a source -> head to a shop @self KNOWS that stocks the kind.
    (try
      (role ?shop [k shop] (not (spatial @self building ?shop))
                    (select (score (near @self ?shop)) (policy roulette unknown-last))
        (when (empty (spatial @self hold ?kind)))
        (declare-utility fallback)
        (effects (maintain-proposal {@self go-to ?shop}))))
    ; at a source, unwatched -> take a shelf item of the kind (the guarded snatch).
    (try
      (role ?loot (spatial (spatial @self space) contents) (is-a ?loot ?kind) (select (policy first-match))
        (when (and (empty (spatial @self hold ?kind))
                   (is-a (spatial @self building) [k shop])
                   (= (count (spatial (spatial @self space) contents [k human])) 1)))
        (effects (maintain-proposal {@self take ?loot}))))
    ; concluded: the loot is in hand /caused_by this pursuit -> crime row + succ.
    (try
      (role @self {@self take ? /succ /caused_by ?steal}
        (when (and (not (empty (spatial @self hold ?kind)))
                   (is-a (spatial @self building): ?shop [k shop])))
        (effects
          (any {?shopkeeper own ?shop})
          (record-crime @self ?shopkeeper opportunist_theft steal ?kind @u)
          (set-outcome ?steal /succ))))))
