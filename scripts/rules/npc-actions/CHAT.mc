; CHAT - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self CHAT ?target}
  (duration procedural)
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (anim-male Motion_Male_Stand_Listen_01)
    (anim-female Motion_Female_Stand_Conversation_Acting_01)
    (anim-flags loop reset)
    (state standing)
    (preroll 0.0) (in 0.2) (out 0.2)))
