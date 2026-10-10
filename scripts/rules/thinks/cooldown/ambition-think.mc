; ----------------------------------------------------------------------------
; ambition.mc - instrumental homicide genesis: ambition (think).
;
; Sibling of covet-inheritance.mc. A cold, ambitious actor who is the CLEAR
; HEIR-APPARENT of their organisation's leadership post - the most-senior employee
; below the org-head - murders the incumbent to take the seat. The victim is an
; OBSTACLE (an innocent who holds the post), not a wrongdoer.
;
; PURE .mc, per-mind honest (the old (ambition-target ...) C++ verb entered every
; colleague's mind + scanned the register). The selection is now a role-cast JOIN
; over what @self KNOWS, exactly like covet's:
;   - @self must be seated at an org, SENIOR grade, and NOT the head - the honest
;     clear-deputy proxy: senior is the top rung below the head, so removing the head
;     lifts @self (promote_on_vacancy). All self-reads of my own job object.
;   - ?victim is the incumbent head: a colleague I LEARNED from the staff register
;     (read-roster) whose job at MY org is-a org-head. The JOIN {?victim job.org ?org}
;     shares my own org object - a read of my own beliefs, no telepathy.
;   - (when ...) is the disposition pre-gate (ambition = mean(machiavellianism,
;     narcissism), scaled by disinhibition, at the 0.03 base rate).
;   - (effects ...) mints the intent {@self intent kill <head>} caused by his power-aim,
;     the life-aim the ambition is (the succession stake lives in the role gates). The
;     intent ends when the
;     victim dies and latches the one-time impulse so it is not re-rolled.
; pursue-kill (thinks/hot/kill-think.mc) carries it out. The payoff is real:
; promote_on_vacancy (propagate_death) lifts the actor into the vacated head rank.
;
; Kept rare by design (0.03 base rate + a senior non-head is uncommon). To A/B the
; motive, rename / remove this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------


(intender ambition
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  ; @self: a credible successor - seated (binds my org), senior grade, not the head.
  (role @self {@self machiavellianism ?machiavellianism}
              {@self narcissism ?narcissism}
              {@self inhibition ?inhibition}
              {@self life-aim [k power-aim]}:?aim
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self job.org ?org}
              {@self job.level [k senior]}
              -{@self job [k org-head]}

    ; The incumbent head I stand behind - a known colleague (learned from the staff
    ; register by read-roster) whose job is-a org-head. read-roster only mints coworkers
    ; from MY own register, so a known org-head IS my org's head; the (when) below pins it
    ; to my current ?org with a LIVE chain read (a cross-role JOIN on the job.org chain in
    ; a cached role filter is unsupported, so the org match lives in the gate, not the role).
    (role ?victim {?victim isa [k human], condition [k alive]}
                  {?victim job [k org-head]}
                  (select (policy first-match))

      ; Same-org pin + disposition pre-gate. ambition = mean(machiavellianism, narcissism);
      ; propensity = (1 - inhibition) * ambition; fire at 0.03 * propensity. The tip fires
      ; ONCE then the latch holds it; drop the drive if the victim dies.
      (when (and {?victim job.org ?org}
                 -{?victim condition [k dead]}
                 (latch-eval (chance (* (crime-scale) 0.03
                                (* (- 1.0 ?inhibition)
                                   (* 0.5 (+ ?machiavellianism
                                             ?narcissism))))))))

      (declare-utility want)
      (effects
        (maintain-intent {@self intent kill ?victim} /caused_by ?aim)))))
