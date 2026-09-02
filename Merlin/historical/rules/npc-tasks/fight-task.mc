; ----------------------------------------------------------------------------
; fight (npc-task) - the victim's counter-episode, morally NEUTRAL. When someone is
; attacked (they WITNESS a violent act against themselves) they may fight back; a failed
; murder attempt becomes an emergent brawl - the aggressor keeps up their killing task
; (CHOKE / TRIGGER_FIREARM), the victim answers with fists (PUNCH). fight carries NO
; construed-act/theme of its own: the blows are where blame lives, and the victim's PUNCH
; is exonerated at appraisal time because it traces (/caused_by) to the assault on them.
;
; Latched by fight_defence (begin-proposal off the witnessed violent act); it PERFORMS
; the counter (PUNCH the foe) and CONCLUDES bottom-up when the foe is down (dead or
; knocked out) or gone. A PUNCH knockout ends the foe's turn, so a victim can win by
; battering their attacker senseless.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-task {@self fight ?foe}:?fight-rel
  (track-skill-level [k martial])
  (tar human)
  (and
    ; THE COUNTER-BLOW: co-present with a conscious, living foe - PUNCH them.
    (try
      (when (and (spatial ?foe co-located @self)
                 -{?foe condition [k dead]}
                 (not (attr-is ?foe awareness unconscious))))
      (utility survival always-pick)
      (effects (maintain-proposal {@self STRIKE ?foe punch})))

    ; CONCLUDE: the threat is neutralized (foe dead or knocked out) or gone (fled /
    ; no longer co-present) - the brawl is over.
    (try
      (when (or {?foe condition [k dead]}
                (attr-is ?foe awareness unconscious)
                (not (spatial ?foe co-located @self))))
      (effects (set-outcome ?fight-rel /succ)))))
