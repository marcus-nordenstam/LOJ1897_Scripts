# rules/thinks/classify

Derived-signal classifiers (the derived-signals program,
`Merlin/docs/derived_signals_program.md`). A classifier is an ordinary `(think ..)`
that derives a per-mind category or disposition belief from what the mind already
holds. Its rule name and its file name both begin `classify-`, and each file holds
ONE classifier think (mlint `classifier-layout`). Classifiers that belong together
sit in a sub-folder; the notes shared by a sub-folder's classifiers are below.

Two shapes:

- **Band / toggle / argmax classifiers** -> thinks whose effect is
  `(mint-band ...)` (hysteresis + end-old/begin-new). Inputs are declared as
  `(role @self {@self <input>})` self-belief conjuncts, so a
  classifier is gated reactively - it only runs for minds whose inputs are
  present, and re-bands when they change. A `(cooldown 1 m)` paces the re-band
  where the inputs drift continuously (respectability, devoutness, conduct,
  contentment, life-aim); the rest re-band whenever an input belief changes.

- **Value dims** (the magnitudes a fusion or utility reads, never minted as a
  belief) stay `(def ...)` expressions, inlined by consumers - not rules.

Prompt state transitions (physical-mobility on death/injury, fallen-woman on
affair exposure) are minted by their triggering rule, not a classifier here.

## devoutness/

The observance reading banded to the piety-band kinds. Recency-weighted
worship-episode evidence: a monthly churchgoer saturates devout, a quarterly
attender reads observant, a 2-year lapse decays through observant to secular. The
floor band (secular) means every derived NPC carries a reading. @self bands its OWN
worship memory; a tracked other is banded from the worship episodes THIS mind holds
of them (witnessed / heard) - the church-going pretender fools it by design.
(evidence ...) is per-observer and non-telepathic.

## dispositions/

The higher-order traits, each minted as a `{@self <dim> <float>}` self-belief from
the first-order traits and the derived states beneath it, so a rule reads the value
off its own role like any other belief. Moods settle nightly, so the dims that fold
a mood recompute daily; the rest fold slow inputs and recompute monthly.

## identities/

Role identities. Each toggles ONE `{@self identity [k role <X>]}` via mint-band at
0.5 - a single band IS a toggle (>= 0.5 begins, < 0.5 ends) and the held-scan
matches only the declared kind, so the identities never disturb one another
(identity is NON-@excl: an NPC holds several at once). Ported from the C++
classify_identities fold.

All but coward gate on `{@self class-situation ?}` - present on every NPC, so each
identity re-evaluates every pass and can flip OFF when its condition lapses.

- gentleman / lady: the gendered standing of a middle-or-upper class NPC. An NPC
  with no gender attr reads as neither.
- machiavellian / sadist: the two Dark Tetrad identities - the homonymous trait
  attr against a floor. 0.65 sits near the top third of the population (gaussian
  mean 0.5, sigma 0.15).
- christian / merchant / steward: the identity a membership or a post confers. A
  kind target matches the OBJECT's kind up the is-a chain, so these read the org /
  job object directly - no walk, no isa hop. `church` is declared twice (the
  building and the org), so the org path is spelled out.

## prototypes/

Shape B toggles. Each is a `(mint-band {@self prototype} <bool> [k prototype
<proto>] 0.5)`: a single band at 0.5 IS a toggle (bool >= 0.5 begins the kind,
< 0.5 ends it), and mint-band's held-scan only matches the ONE declared kind, so a
toggle never disturbs the other (non-@excl) prototype beliefs. Booleans compose as
products of (believes)/(>=)/(<=) 0-or-1 terms; OR = (clamp (+ ...) 0.0 1.0). Gated
on a PERSISTENT input band (plus the held prototype itself, for inputs like craving
that can end) so the toggle can flip OFF when the condition lapses.

for-hire: CAPABILITY (a lethal skill OR raw brute strength) AND REASON (economic
desperation OR a callous, disinhibited bad-seed). Split into a skilled path
(classify-for-hire-skilled: the role binds a martial / garrotting skill) and a
MUTUALLY-EXCLUSIVE brute path (classify-for-hire-brute: the role excludes such a
skill), so the two never clobber the shared for-hire toggle and a skill-loss hands
the subject cleanly to the brute path. "disinhibition" is the externalizing fold,
as in classify-go-between.

The skill-level reads are shape-correct: the action pipeline emits
`{@self skill-level [k <domain>] [k <rung>]}`, a DOMAIN-kind target, which is what
these clauses match. They stay quiet only while no act accruing martial /
garrotting skill is being performed.

TODO - same gap as classify-go-between: this is SELF-knowledge and nothing reads
it. An employer cannot see another mind's willingness to kill for money. Needs a
per-observer classify-others-for-hire (the classify-others-repute template) fed by
legal evidence only - witnessed violence, reputation, gossip, or the solicitation
itself, since asking someone and hearing their answer IS how you learn it. Then
hire-assassin-task.mc prefers a believed hireling and proposes ACQUIRING that
belief when it holds none.

## repute/

Per-observer repute. Each mind bands a person's public respectability into
`{X repute [k repute ...]}` from (repute-fold X) - the seven-term mean over that
person's conduct bands + devoutness + decorum + per-observer chastity
(dimensions.mc). ONE fold, ONE belief, serving both cases; the only difference is
which mind's inputs it reads, never the algorithm:

- classify-self-repute: `{@self repute}` from @self's OWN inputs, which are
  complete - so self-repute IS the truth (mint-band).
- classify-others-repute: `{?other repute}` from only what @self has learned of
  them (mint-band-about, landing in @self's own pool).

Reputation is per-observer and non-telepathic: two minds hold different repute of
the same third party, a stranger reads middling (fair defaults), and an observer
with only negative evidence caps a person below exemplary - you do not credit a
prestige-marriage-grade character to someone you know nothing good about. There is
no separate "true respectability" label; the gap that used to be called the
blackmail stake is just the difference between what a mind knows of itself and
what others have learned. (Bands: the historical respectability thresholds.)
