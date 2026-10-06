; ----------------------------------------------------------------------------
; denounce ?innocent ?victim - a letter to the police naming ?innocent as ?victim's
; killer, signed with a made-up name. The alias is drawn once and kept on the task,
; so every step writes the same letter; the hand is the writer's own, which WRITE
; stamps on it whatever name it is signed with.
; ----------------------------------------------------------------------------

(task {@self denounce ?innocent ?victim}:?denounce
  (tar [k human] @object)
  (aux [k human] @object)
  (role ?my-home {@self home ?my-home}
    (declare-utility errand)
    ; Ordered: a posted letter ends it, a dead innocent voids it, and a letter in hand is
    ; finished before another is made.
    (stable-or
      (try
        (when {@self send-mail ? ? /succ /caused_by ?denounce})
        (effects
          (bb-clear ?denounce alias)
          (set-outcome ?denounce /succ)))
      (try
        (when (not (alive ?innocent)))
        (effects
          (bb-clear ?denounce alias)
          (set-outcome ?denounce /fail)))
      (try
        (role ?ltr [k forged-letter] (spatial ?ltr co-located @self)
                                     {@self WRITE ?ltr ? /succ}
                                     -{@self send-mail ?ltr ? /succ}
          (role ?out [k outgoing-mail-stack] (within-place ?out ?my-home)
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
              (if (not (bb-any ?denounce alias))
                (then
                  (bb-write ?denounce alias
                    (sample-name (attr @self gender)
                                 (table-sample-weighted nationality_dist value weight)
                                 [k middle]))))
              (maintain-proposal
                {@self write-doc ?ltr
                       (set-msg-rider
                         (set-msg-rider (nl-written-msg "?innocent killed ?victim")
                                        address ?station-address)
                         author (bb-read ?denounce alias))})))))
      (try
        (effects (maintain-proposal {@self CREATE-ENTITY [k forged-letter]}))))))
