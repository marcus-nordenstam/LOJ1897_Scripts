# CLAUDE.md - Legends of Justice: 1897 Game Scripts

This is the ground-truth for all Merlin behavioural scripts, ontology, environment, nat_lang
and other scripts relating to the Legends of Justice: 1897 video game.

The Dropbox path `C:/Users/realm/Dropbox/CnE/LOJ1897/Game/Content/Merlin/` is a mirror copy
updated by the GrymEngine Player's CMake publish build - do NOT treat it as authoritative.

THERE IS ONE CORPUS, and it is `scripts/` - the module root every process loads (the
directory holding merlin_limits.txt + ontology/ + rules/). The old `historical/` and
`interactive/` split is GONE: a mind is simulated at PRESENTED LOD (near the camera,
animated, real motors) or UNPRESENTED LOD (out of view, movement by relocation at
completion), hsim pins every mind to unpresented, and where behaviour differs by LOD the
difference is AUTHORED inside the rules, never expressed by which folder a rule sits in.
The corpus language is `.mc`; `.hs` and `.ms2` are dead extensions.

scripts/
    rules/          THE behaviour corpus, loaded whole.
                    npc-actions/  one (npc-action ..) per file - the physical primitives
                    npc-tasks/    (npc-task ..) orchestrators and concrete tasks
                    npc-think/    the drivers, plus the audit/, hot/ and cooldown/ lanes
                    classifiers/  banding rules over what a mind already believes
                    reflexes/     the reflex rules
                    startup/      what runs once when a mind is born
                    legacy/       dead .evt files, kept for reference only
    funcs/          authored (define-func ..) bodies - content the engine calls by name
                    (run_physiology at each act completion, adopt-heard-msg per utterance,
                    the /nightly town post)
    macros/         macro expansions shared by the rules
    tables/         authored data the rules and the engine read by table lookup
    ontology/       the game's ontology (.mon, one s-expr tree language): things.mon the physical
                    tree with its pops, concepts.mon the abstract tree, the name pools, states.mon
                    + tasks.mon the relation definitions, attrs.mon + spatials.mon the attr /
                    spatial / struct definitions, ontology.mon the (using ..) index
    definitions/    run configs (.mc): historical_1yr.mc and its siblings. hsim's --cfg
                    path is relative, so run hsim from here
    nat_lang/       grammar packs and the phrasebook, for converting between the Merlin
                    knowledge representation and natural language
    tests/          corpus-side probes
    ms1/            identity drivers and reactions
    interactive/    THE DEAD TREE, nothing loads it: 57 .ms2 skill and reasoning files, 47
                    .act binding files (still read by GrymEngine's ActionBindingTable), a
                    knowledge/ folder and actions_hs/ holding two unported .mc actions.
                    It is deleted file by file as each skill is ported into rules/ or ruled
                    dead - see docs/plans/hse_unification_plan.md section 6 in the Merlin
                    repo. Do NOT author anything new here.

AUTHORING RULES live in `Merlin/CLAUDE.md` (the NPC behaviour authoring conventions) and are
enforced by mlint:

    E:/Repos/Merlin/cmake-build-release-visual-studio/src/apps/mlint/mlint.exe --rulebook E:/Repos/LOJ1897_Scripts/scripts/rules

Run it on every rule change, before committing. Exit 0 clean, 1 ISSUE findings, 2 corpus
load error; never commit NEW findings.

ROLE-IFY BY DEFAULT. Belief conditions on @self or on a candidate belong in cached
(role ..) filters (shared-witness joins, [k K]:?x kind-cast identity, chain labels), NOT in
live (when ..) gates; (when) keeps only the non-belief tests (age / date / no-goal / chance)
and binds that thread to the effects. Never write the 2-arg (believes @self {..}) - the
1-arg form is identical and cache-eligible.

THE SCRIPTS REPO MOVES WITH THE ENGINE. A Merlin baseline run names both repos' HEADs, and
an older checkout of this one will not reproduce it: a new table mints new terms, which
renumbers the hstr table and changes the run's digest.
