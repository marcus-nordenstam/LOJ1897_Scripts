; ----------------------------------------------------------------------------
; situations.hsc - F3 derived-situation tuning data.
;
; Loaded by Merlin at ontology-load time (hsim::derive_load_norms, called from
; t_simulator::load_ontology). Editing this file re-tunes the F3 four-layer
; derived model - dimensions -> situations -> prototypes - with no rebuild.
; See Docs/hsim_social_events_plan.md F3.5 and src/lib/hsim/hsim_derive.cc.
;
; The classifier LOGIC is code (hsim_derive.cc); only the thresholds, fusion
; weights and the two rank curves live here. Every value below is also the
; built-in C++ default - the model runs unchanged if this file is removed.
;
; Dimensions are integers on a 0..100 scale.
; ----------------------------------------------------------------------------

; ---- dimension tuning ------------------------------------------------------
; Scalars feeding the wealth / prestige / piety / sobriety / breeding
; classifiers. unemployed-* are the no-job floors; creditor-wealth-penalty is
; the wealth lost per outstanding `owe`; won-prestige-* the capped bonus per
; sporting victory; craving-sobriety-cap the sobriety ceiling once a `craving`
; has formed; default-breeding the fallback when the seeded belief is absent.
(dimension-tuning
  :unemployed-wealth        30
  :creditor-wealth-penalty  15
  :unemployed-prestige      15
  :won-prestige-bonus        4
  :won-prestige-cap         20
  :default-breeding         55
  :secular-piety            25
  :churchgoer-piety         85
  :craving-sobriety-cap     15)

; ---- rank curves -----------------------------------------------------------
; Six values each, indexed by job rank 0..5 (trainee apprentice junior
; regular senior org_head): wealth income, and public standing.
(income-by-rank    25 35 50 65 80 95)
(prestige-by-rank  20 20 30 45 65 90)

; ---- economic_situation <- wealth ------------------------------------------
; Ascending upper bounds. wealth at or above prosperous-max reads `wealthy`.
(economic-situation
  :destitute-max   15
  :poor-max        30
  :struggling-max  45
  :stable-max      60
  :comfortable-max 75
  :prosperous-max  90)

; ---- respectability_situation <- mean of the seven conduct dimensions ------
; honesty + sobriety + piety + diligence + chastity + decorum + generosity,
; divided by 7. Ascending upper bounds; a score at or above respectable-max
; reads `exemplary`.
(respectability-situation
  :scandalous-max   20
  :disreputable-max 40
  :questionable-max 60
  :respectable-max  80)

; ---- conduct dimensions (Phase 8) ------------------------------------------
; chastity: a high prior (chastity-base), less chastity-adultery-penalty per
; extra-marital partner. criminality: a low base raised criminality-per-crime
; per recorded criminal act. gambling-*-penalty: the flat sobriety / wealth hit
; for a standing gambling habit (the play_game act-record). honesty / decorum /
; generosity / aggression are pure trait folds and need no tuning.
(conduct
  :chastity-base             85
  :chastity-adultery-penalty 30
  :criminality-base           5
  :criminality-per-crime     25
  :gambling-sobriety-penalty 25
  :gambling-wealth-penalty   15)

; ---- class_situation <- weighted breeding + prestige + wealth --------------
; breeding dominates (the lineage anchor). middle-min / upper-min are lower
; bounds on the fused score; a score below middle-min reads `lower`.
(class-situation
  :weight-breeding 5
  :weight-prestige 3
  :weight-wealth   2
  :middle-min      40
  :upper-min       70)

; ---- social_trajectory -----------------------------------------------------
; The gap between achieved standing ((prestige + wealth) / 2) and the
; inherited breeding anchor; a gap of +/- margin or more counts as a move.
(social-trajectory
  :margin 15)

; ---- prototype gates -------------------------------------------------------
; nouveau_riche: wealth >= nouveau-wealth-min carried by breeding <=
; nouveau-breeding-max. self_made_man: a low-born origin, breeding <=
; self-made-breeding-max.
(prototype-tuning
  :nouveau-wealth-min     60
  :nouveau-breeding-max   35
  :self-made-breeding-max 40)

; ---- felt-life dimensions (F4.6) -------------------------------------------
; belonging: the warmth-bond need is belonging-min-need plus up to
; belonging-need-span scaled by Extraversion. purpose: no calling / a calling
; matched by a skill / an unmatched calling. autonomy: a base adjusted for
; gender, coverture, property and the craving drive. contentment-neutral is
; the reading for a mind that holds no mood.
(felt-life
  :belonging-min-need          1
  :belonging-need-span         5
  :purpose-no-calling         50
  :purpose-served             85
  :purpose-unserved           20
  :autonomy-base              55
  :autonomy-female-penalty    20
  :autonomy-coverture-penalty 20
  :autonomy-property-bonus    20
  :autonomy-craving-penalty   15
  :contentment-neutral        50)

; ---- life_satisfaction <- (belonging + contentment + purpose) / 3 ----------
; The middling band splits on economic security (secure_but_hollow vs
; struggling). fulfilled-min / content-min are lower bounds; adrift-max an
; upper bound.
(life-satisfaction
  :fulfilled-min 72
  :content-min   55
  :adrift-max    35)
