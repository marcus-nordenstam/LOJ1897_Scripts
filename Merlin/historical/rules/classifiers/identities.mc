; ----------------------------------------------------------------------------
; Role identities (classifiers). Each toggles ONE {@self identity [k role <X>]}
; via mint-band at 0.5 - a single band IS a toggle (>= 0.5 begins, < 0.5 ends) and
; the held-scan matches only the declared kind, so the identities never disturb one
; another (identity is NON-@excl: an NPC holds several at once). Ported from the
; C++ classify_identities fold; coward-role keeps its own file.
;
; All gate on {@self class-situation ?} - present on every NPC, so each identity
; re-evaluates every pass and can flip OFF when its condition lapses.
; ----------------------------------------------------------------------------

; parent: holds a child belief.
(npc-think classify_parent_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (prob {@self child ?}) [k role parent-role] 0.5)))

; spouse: married.
(npc-think classify_spouse_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (prob {@self spouse ?}) [k role spouse-role] 0.5)))

; worker: holds a job.
(npc-think classify_worker_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (prob {@self job ?}) [k role worker-role] 0.5)))

; gentleman / lady: the gendered standing of a middle-or-upper class NPC. An NPC
; with no gender attr reads as neither.
(npc-think classify_gentleman_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (* (= (attr @self gender) [k male])
         (clamp (+ (prob {@self class-situation [k class-situation middle]})
                   (prob {@self class-situation [k class-situation upper]})) 0 1))
      [k role gentleman-role] 0.5)))

(npc-think classify_lady_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (* (= (attr @self gender) [k female])
         (clamp (+ (prob {@self class-situation [k class-situation middle]})
                   (prob {@self class-situation [k class-situation upper]})) 0 1))
      [k role lady-role] 0.5)))

; The two Dark Tetrad identities - the homonymous trait attr against a floor.
; 0.65 sits near the top third of the population (gaussian mean 0.5, sigma 0.15).
(define-macro identity-machiavellian-min () 0.65)
(define-macro identity-sadist-min ()        0.65)

(npc-think classify_machiavellian_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (>= (attr @self machiavellianism) (identity-machiavellian-min))
      [k role machiavellian-role] 0.5)))

(npc-think classify_sadist_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (>= (attr @self sadism) (identity-sadist-min))
      [k role sadist-role] 0.5)))

; christian / merchant / steward: the identity a membership or a post confers. A
; kind target matches the OBJECT's kind up the is-a chain, so these read the org /
; job object directly - no walk, no isa hop. `church` is declared twice (the
; building and the org), so the org path is spelled out.
(npc-think classify_christian_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity} (prob {@self member-of [k org gov church]})
      [k role christian-role] 0.5)))

(npc-think classify_merchant_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity} (prob {@self job [k merchant]})
      [k role merchant-role] 0.5)))

(npc-think classify_steward_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity} (prob {@self job [k steward]})
      [k role steward-role] 0.5)))

; ---- skill-driven trade / talent identities --------------------------------
; The COMPETENCE confers these, not the job title: a domain at `competent` or
; above on the pipeline-emitted {@self skill-level [k <domain>] [k <rung>]}.
; `competent` is the same rung position the retired C++ fold's `trained` held on
; the old 3-rung ladder - see classifiers/calling.mc for that judgement call.
;
; DORMANT until acts decorated (track-skill-level <domain>) actually run - no
; skill-level belief exists in a 2-year run today, so none of these can fire yet.
;
; DIVERGENCE from the C++ fold, deliberate and flagged: that version walked the
; held domains and used else-if ordering per domain, so medicine beat the generic
; academic-field and music beat the generic performance-art FOR THAT DOMAIN. These
; folds test kinds independently, so an NPC competent in BOTH medicine and history
; reads as physician AND scholar (the C++ gave only physician). Revisit once real
; skill distributions exist - the fix wants a per-domain reduction, not more terms.
(define-macro competent-in (?domain)
  (clamp (+ (prob {@self skill-level ?domain [k competent]})
            (prob {@self skill-level ?domain [k proficient]})
            (prob {@self skill-level ?domain [k virtuoso]})) 0 1))

(npc-think classify_physician_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (competent-in [k medicine])
             [k role physician-role] 0.5)))

(npc-think classify_lawyer_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (competent-in [k law])
             [k role lawyer-role] 0.5)))

; scholar: a scholarly academic-field, EXCLUDING the two general-schooling tiers -
; a secondary graduate is not a scholar.
(npc-think classify_scholar_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (* (competent-in [k academic-field])
         (- 1 (competent-in [k primary-school-curriculum]))
         (- 1 (competent-in [k secondary-school-curriculum])))
      [k role scholar-role] 0.5)))

(npc-think classify_soldier_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (competent-in [k martial])
             [k role soldier-role] 0.5)))

(npc-think classify_musician_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (competent-in [k music])
             [k role musician-role] 0.5)))

; artist: a performance art that is NOT music (a musician is not a generic artist).
(npc-think classify_artist_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects
    (mint-band {@self identity}
      (* (competent-in [k performance-art]) (- 1 (competent-in [k music])))
      [k role artist-role] 0.5)))

(npc-think classify_sportsman_identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?})
  (effects (mint-band {@self identity} (competent-in [k athletics])
             [k role sportsman-role] 0.5)))
