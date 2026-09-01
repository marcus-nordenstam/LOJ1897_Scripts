; ----------------------------------------------------------------------------
; affair_fallout.hs - broad, NON-lethal betrayal fallout (homicide_motive_realism
; pattern-4 + divorce). The counterpart to betrayal_kill.hs: where that pass is
; the murderous tail, this is what happens to EVERYONE else who is betrayed -
; the great majority who react without violence.
;
; PURE .hs (no C++ generator):
;   - ?partner is a spouse or lover the actor believes keeps a third-party
;     lover (the same discovery shape as betrayal_kill.hs - the actor's OWN
;     beliefs, no mind peek); ?interloper is the JOIN role over those beliefs;
;   - the monthly discovery chance (0.12) surfaces a standing affair over
;     time, not instantly;
;   - SUPPRESS-EXPOSE-ON-KILL: an actor who already holds a kill goal on
;     either corner of the triangle keeps the secret - no public fallout, no
;     divorce - exposing the affair would advertise the motive;
;   - the betray-act reflex rows mint anger@partner + contempt@interloper + a
;     humiliation PRESSURE; the pressure feeds the ordinary deliberation table
;     (humiliation -> confront_privately / expose / humiliate / withdraw), so
;     the betrayed spouse confronts / exposes / shames the cheat on later
;     ticks. No kill goal is minted here;
;   - DIVORCE: a betrayed HUSBAND (never a wife - the period gives her no such
;     remedy) may put the marriage away at 0.35 x decorum (an unknown decorum
;     reads 0.5): both spouse bonds end, and the {husband divorce wife}
;     act-record lands in BOTH minds (gossipable - the town learns whom he put
;     away; the repudiation-act reactions mint her shame / grief / status-loss);
;   - THE FALLEN WOMAN: a divorced wife is marked for life - {@self prototype
;     fallen-woman} in her mind and {wife prototype fallen-woman} in his (the
;     gossip channel carries her disgrace; betrothal / love_match exclude her).
;     She is cast out of the marital home (a live parent's roof, else a
;     rowhouse; failing all she stays on in disgrace - expel-divorced-wife) and
;     turned out of any reputation-based post (dismiss-from-service).
;
; Once a spouse divorces, the bond is gone, so they are no longer a
; betrayed-spouse candidate. To A/B, rename / remove this file (runtime-loaded).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think affair_fallout
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self )
  ; The unfaithful partner: a spouse or lover of the actor's.
  (role ?partner (any_human ?partner)
    {@self spouse|lover ?partner}
    (select (policy first-match)))
  ; The interloper: the third-party lover the actor believes ?partner keeps -
  ; a JOIN role over the actor's OWN beliefs (no mind peek). Excludes
  ; ?partner's known spouse; the role machinery never casts @self. No known
  ; affair -> no activation, and the fallout never rolls.
  (role ?interloper (any_human ?interloper)
    {?partner lover ?interloper}
    -{?partner spouse ?interloper}
    (select (policy first-match)))

  ; Recourse to an APPRAISED betrayal (the betray-act reflex rows minted the anger @ partner),
  ; and only while @self is not answering it lethally: a killer keeps the secret,
  ; since exposing the affair would advertise the motive.
  (when (and {@self emotion [k anger] ?partner}
             -{@self kill ?partner}
             -{@self kill ?interloper}))

  (effects
    ; Divorce: the husband's remedy alone; the proper / high-decorum are likeliest
    ; to cut the tie. PROPOSE the divorce task (divorce-task.hs performs the
    ; repudiation); once put away, the standing divorce record bars a re-propose.
    (if (and {@self spouse ?partner}
             {@self gender [k male]}
             -{@self divorce ?partner /ever}
             (chance (* 0.35 (target-or @self decorum 0.5))))
        (then (begin-proposal {@self divorce ?partner})))))
