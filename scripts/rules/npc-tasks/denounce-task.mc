; ----------------------------------------------------------------------------
; denounce ?innocent ?victim - a letter to the police naming ?innocent as ?victim's
; killer, signed with a made-up name. The alias is drawn once and kept on the task,
; so every step writes the same letter; the hand is the writer's own, which WRITE
; stamps on it whatever name it is signed with.
; ----------------------------------------------------------------------------

(npc-task {@self denounce ?innocent ?victim}:?dn-rel
  (tar [k human] @object)
  (aux [k human] @object)
  (role ?my-home {@self home ?my-home}
    (utility errand)
    ; Ordered: a posted letter ends it, a dead innocent voids it, and a letter in hand is
    ; finished before another is made.
    (stable-or
      (try
        (when {@self send-mail ? ? /succ /caused_by ?dn-rel})
        (effects
          (bb-clear ?dn-rel alias)
          (set-outcome ?dn-rel /succ)))
      (try
        (when (not (alive ?innocent)))
        (effects
          (bb-clear ?dn-rel alias)
          (set-outcome ?dn-rel /fail)))
      (try
        (role ?ltr [k forged-letter] (spatial ?ltr co-located @self)
                                     {@self WRITE ?ltr ? /succ}
                                     -{@self send-mail ?ltr ? /succ}
          (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home)
            (effects
              (check (substantial (attr ?ltr writing)))
              (check (substantial (attr ?ltr destination)))
              (maintain-proposal {@self send-mail ?ltr ?out})))))
      (try
        (role ?ltr [k forged-letter] (spatial ?ltr co-located @self)
                                     (unsubstantial (attr ?ltr writing))
          (role ?station [k police-station] {?station address ?station-address}
            (select (policy first-match))
            (effects
              (if (not (bb-any ?dn-rel alias))
                (then
                  (bb-write ?dn-rel alias
                    (sample-name (attr @self gender)
                                 (table-sample-weighted nationality_dist value weight)
                                 [k class-situation middle]))))
              (maintain-proposal
                {@self write-doc ?ltr
                       (set-msg-rider
                         (set-msg-rider (nl-written-msg "?innocent killed ?victim")
                                        address ?station-address)
                         author (bb-read ?dn-rel alias))})))))
      (try
        (effects (maintain-proposal {@self CREATE-ENTITY [k forged-letter]}))))))
