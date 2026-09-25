; ----------------------------------------------------------------------------
; bury (npc-action) - the priest's burial rite act. The planning thinks (bury_route /
; bury_onsite) live in npc-think/intra-day/bury_think.mc.
;
;   bury_action (act): perform the rites - the verdict and tombstone chronicle rows -
;     realize the interment, then destroy the corpse and end the act. The corpse is a
;     SINGLE known role-cast object destroyed in the act (safe: no mark, no sweep, no
;     in-flight role walk). SPEAKING the interment is NOT this act's job: announce_burial
;     (bury_think.mc) proposes its own {@self SAY ..} off the ended rite, so the words
;     compete and are said by the ONE speech act like every other utterance.
;
; Death / burial KNOWLEDGE is PULLED, never pushed. Co-present mourners learn the death
; by SEEING the corpse and the interment by hearing the priest announce it; an absent mind
; learns only through a real channel of its own (perceiving the corpse, or reading a death
; notice). The rite writes into NO other mind.
; ----------------------------------------------------------------------------

(npc-action {@self BURY ?corpse}
  (motor body legs)
  (duration (seconds 60 min))
  (effects
    ; The burier READS the body before it goes in the ground: any blemish of the
    ; wound family on any part is a violent reading. A poisoning leaves none, so it
    ; passes as natural - the divergence the verdicts query measures.
    (bind 0 ?violent)
    (for-each ?part (spatial ?corpse parts /env)
      (for-each ?blem (attr-values ?part blemishes)
        (if (is-a ?blem [k wound]) (then (bind 1 ?violent)))))
    (write-chronicle verdict deceased ?corpse cause (attr ?corpse death-cause) violent ?violent)
    (write-chronicle tombstone name ?corpse born (year (attr ?corpse birth-date))
                     cause (attr ?corpse death-cause))
    (realize-destroyed ?corpse internment [k internment buried] BURY)
    (destroy-entity ?corpse)
    (set-outcome {@self BURY ?corpse} /succ)))
; go_action (the shared travel act) lives in npc-actions/go_action.mc.
