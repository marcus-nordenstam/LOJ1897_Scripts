# CLAUDE.md - Legends of Justice: 1897 Game Scripts


This is the ground-truth for all Merlin behavioural scripts, ontology, environment, NatLang and other scripts relating to the Legends of Justice:1897 video game.

The Dropbox path `C:/Users/realm/Dropbox/CnE/LOJ1897/Game/Content/Merlin/` is a mirror copy updated by the GrymEngine's Player's CMake publish build — do NOT treat it as authoritative.


The Merlin folder holds most of it:

ACTIONS - home of all Merlin action .act files, which define action bindings and plugs into Grym's animation system
          Note that the actual action implemention can be found in c++ header files in the GrymeEngine/Apps/Player app.
Behaviour - all NPC behaviour scripts (in .mc files)
Env - all Merlin environment definitions (population archetypes, attrs etc)
Knowledge - NPC startup knowledge etc
NatLang - grammar rules for converting between the Merlin knowledge representation and natural language
Ontology - the game's ontology

