# Crime templates - authoring backlog

The unified-event engine (Phase B of the historical sim) is generic over
crime templates: each one is a `.evt` data file consumed by the parser and
tick engine.  The engine has no per-template C++.  Adding new templates is
a content task, not a code task.

The 13 templates already authored exercise every major mechanic the engine
provides.  The remaining 37 from the original list are content TODOs.  They
should each be authored as a focused `.evt` file, taking advantage of the
distinct mechanics already demonstrated:

  - Role bindings with kin / lover / enemy / inheritance / outsider gates
  - Dark-tetrad disposition floors per role
  - Multiple effect kinds per template (kill, disappear, attitude_set,
    attitude_delta, emotion_delta, assert_world, propagate,
    region_mood_delta, seed_event)
  - Causal chains via seed_event - keep them rich, don't be shy about
    seeding follow-on templates with realistic lag windows

Themes to also include:
- piracy
- serial killer (only active from 1860's onward so that a serial killer from historical sim could still be active when the game starts)
- an important piece missing in these crime templates are motives.  motives should match against the perpetrator same as
  other conditions, and if we need more rich npc data to be able to find a suitable npc who could, given their data, have
  a required motive, then we should add more data to the npc in the sim.  
- here follows a list of motives.  you could distill these into a possibly shorter list of one-word or one-phrase motives.  the point is that EVERY crime-event template NEEDS to have one or more motives to match against, when casting for roles.  Inheritance or succession
Debt avoidance or financial ruin
Insurance or financial payout
Theft of valuable object (jewels, documents)
Business rivalry or industrial competition
Land ownership dispute
Concealing embezzlement or fraud
Blackmail for money
Desperation due to poverty
Smuggling or illicit trade profit
Romantic jealousy
Unrequited love
Love triangle conflict
Obsession or fixation
Revenge for betrayal
Preventing scandalous affair from being exposed
Forcing or preventing a marriage
Eliminating a rival suitor
Protecting a lover’s reputation
Crime of passion in the moment
Preserving family honor
Avoiding public scandal
Protecting aristocratic lineage
Concealing illegitimacy
Maintaining social rank or position
Silencing gossip or witnesses
Career advancement (military, clergy, politics)
Avoiding disgrace or exile
Covering up past disgrace
Preventing exposure of double life
Madness or mental instability
Paranoia or delusion
Compulsion or uncontrollable urge
Pride or wounded ego
Envy
Hatred built over time
Fear (of exposure, punishment, loss)
Desire for control or dominance
Thrill-seeking or curiosity
Moral justification (“they deserved it”)
Personal revenge for past wrong
Generational or family revenge
Vigilante justice
Retaliation for betrayal
Revenge for ruined reputation
Justice for a loved one
Settling an old score
Punishing perceived immorality
Revenge for exploitation or abuse
Symbolic revenge (against class, system, or institution)
Scientific experiment gone wrong
Proving a theory or intellectual superiority
Political or revolutionary ideology
Religious fanaticism
Belief in curse or prophecy
Obsession with immortality or legacy
Covering up forbidden knowledge
Testing moral limits
Supernatural belief influencing action
Desire to create fear or legend
Self-defense (real or perceived)
Accident followed by cover-up
Silencing a witness
Preventing discovery of another crime
Mistaken identity
Coercion or blackmail forcing the crime
Protecting a secret (family, political, personal)
Escaping imprisonment or punishment
Eliminating an obstacle to a plan
Opportunistic crime (wrong place, wrong time)


Templates from the user's list still to author:

- the_ghost_as_witness
- the_family_curse_crime           (multi-generation seed_event chain)
- the_locked_crypt_secret
- the_doppelganger_killer
- the_forbidden_wing_mystery
- the_isolated_abbey_crime
- the_storm_night_murder           (gate on storm_cluster_1859 active)
- the_decaying_aristocrat_conspiracy
- the_guilty_narrator
- the_madness_defense
- the_paranoia_spiral
- the_hidden_sin_returns           (long-cooldown + seed dependency)
- the_moral_experiment_gone_wrong
- the_unreliable_witness
- the_split_identity_criminal
- the_fallen_woman_plot
- the_aristocratic_scandal_coverup
- the_impostor_heir
- the_secret_marriage_crime
- the_class_crossing_romance_crime
- the_debt_driven_crime
- the_colonial_mystery
- the_amateur_sleuth_outsmarts_police
- the_chain_of_clues
- the_misleading_evidence_case
- the_disguised_criminal
- the_stolen_object_mystery
- the_analytical_genius_detective
- the_companion_narrator
- the_final_reveal_gathering
- the_supernatural_explained_away
- the_ambiguous_haunting
- the_curse_that_is_real
- the_scientific_horror_crime
- the_possession_crime
- the_reclusive_mastermind

Authoring conventions:
  1. One template per file, named after the template id.
  2. Distinct mechanic from existing files - the engine is a level
     playing field; the *data* is what makes templates differ.
  3. Cooldown_years and max_per_decade_global tuned to the template's
     desired density.
  4. Use seed_event aggressively for templates that are causal followups
     ("revenge", "confession", "hidden_sin_returns").
  5. region_mood_delta and propagate carry the rich social aftermath -
     don't leave templates as pure-kill.
