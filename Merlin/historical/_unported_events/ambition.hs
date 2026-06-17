; ----------------------------------------------------------------------------
; ambition.hs - instrumental homicide genesis: ambition (WS1, the last motive).
;
; Sibling of covet_inheritance.hs and crime_of_passion.hs. A cold, ambitious
; actor who is the CLEAR HEIR-APPARENT of their organisation's leadership post -
; the most-senior employee below the org_head - murders the incumbent to take
; the seat. The victim is an OBSTACLE (an innocent who simply holds the post),
; not a wrongdoer.
;
; The `(generative-ambition)` flag dispatches to hse_engine.cc::
; run_generative_ambition, which (per alive adult, monthly):
;   1. ambition pre-gate (machiavellianism + narcissism, x disinhibition),
;   2. resolves the obstacle via hsim::ambition_target - the org_head of the
;      actor's org, returned ONLY when the actor is that post's clear deputy
;      (so removing the head promotes the ACTOR, not a colleague),
;   3. mints {actor goal {actor kill <head>}} with the actor's `employer`
;      belief as the goal's /cause (chain: "kill <head> <- {@self employer <org>}").
; attempt_harm then consumes the goal and executes a kill method as usual.
;
; The PAYOFF is real: promote_on_vacancy (propagate_death) lifts the most-senior
; surviving co-worker - the actor - into the vacated org_head rank when the
; incumbent dies. Without that backfill this motive would be hollow (the org
; passes to the founder's kin heir, never the killer).
;
; Kept rare by design (k_ambition_base_rate + the clear-deputy requirement, so
; only a handful of NPCs qualify at any time). To A/B, rename/remove this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event ambition
  (nl       "?actor's ambition turns murderous")
  (kind     _ambition)
  (rng-stream perpetration)
  (generative-ambition)

  (roles
    (role ?actor (template any_human))))
