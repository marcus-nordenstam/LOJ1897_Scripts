# CLAUDE.md - Legends of Justice: 1897 Game Scripts


This is the ground-truth for all Merlin behavioural scripts, ontology, environment, nat_lang and other scripts relating to the Legends of Justice:1897 video game.

The Dropbox path `C:/Users/realm/Dropbox/CnE/LOJ1897/Game/Content/Merlin/` is a mirror copy updated by the GrymEngine's Player's CMake publish build — do NOT treat it as authoritative.

The Merlin folder holds most of it:

Merlin simulations are broken into two phases, a non-interactive historical sim (like a pre-roll that generates an initial NPC population), and the actual interative game simulation.  Scripts and data specific to each sim are found in 
historical/ and interactive/ folders.

historical/ - scripts & data for an event & statistics-based simulation
    environment - anything related to the historical simulation environment, including archetypes for the historical sim
    events - higher level 'rules' and actions and planning all folded into one

interactive/ - scripts & data for a rule-based cognitive simulation
    actions - home of all Merlin action .act files, which define action bindings and plugs into Grym's animation system
            Note that the actual action implemention can be found in c++ header files in the GrymeEngine/Apps/Player app.
    behaviour - all NPC behaviour scripts (in .ms2 files)
    environment - environment definitions for interactive sim (population archetypes, attrs etc)
    knowledge - NPC startup knowledge etc

common to both:

npc_traits - the list of hereditary and non-hereditary NPC traits
nat_lang - grammar rules for converting between the Merlin knowledge representation and natural language
ontology - the game's ontology

