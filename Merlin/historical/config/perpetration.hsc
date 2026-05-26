; ----------------------------------------------------------------------------
; perpetration.hsc - PR-3d 2026-05-25.
;
; Method table for the generative-perpetration event (attempt_harm.hse).
; One row per method (33 total: 26 kill methods + 7 non-kill). At fire
; time, run_generative_perpetration walks the actor's standing goal
; beliefs cross-product these rows, filters by :goal-fit + :requires +
; (future :victim-state / :in-season), weighted-samples by
; base * disinhibition * pressure-floor, and dispatches the chosen
; row's :terminal.
;
; Row schema:
;   (method <atom>
;     :goal-fit       <goal-label>...           ; which goals this method satisfies
;     :requires       (<predicate>...)          ; viability gates (control_any wired; others ignored in PR-3d)
;     :victim-state   <atom>                    ; parsed-but-not-yet-gated
;     :in-season      <atom>                    ; parsed-but-not-yet-gated
;     :yields         <evidence-atom>...        ; wound/stain/mark atoms passed to yield_evidence
;     :method-aux     <atom>                    ; rides the band-5 act-anchor's /aux slot
;     :terminal       <terminal-atom>           ; which C++ terminal verb to dispatch
;     :wound-site     <body-part-atom>          ; where wound/stain/mark land (default torso)
;     :pressure-floor <kind> <intensity>        ; weight bias when pressure held
;     :weight         <base>)                   ; base selection weight
;
; PR-3d v1 wires :requires (control_any <kind>) only. Other :requires
; predicates (access_any, has_authority_over, trait gates) are
; documentation - rows fire even when those predicates would fail. A
; follow-up extends the evaluator.
;
; Body-part inventory today: head / left_hand / right_hand / finger /
; eye / mouth / torso. Methods that conceptually target neck/lungs/
; limbs map to nearest existing part (head for neck wounds; torso for
; chest/abdomen/lungs; hand for grip/extremity).
; ----------------------------------------------------------------------------

; ============================================================================
; KILL family (26 methods)
; ============================================================================

; ---- Sharp (3) -------------------------------------------------------------
(method stab
  :goal-fit       kill
  :requires       ((control_any (facets pierce)))
  :yields         puncture_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         1.0)

(method slash
  :goal-fit       kill
  :requires       ((control_any (facets slash)))
  :yields         slash_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.7)

(method decapitate
  :goal-fit       kill
  :requires       ((control_any (facets chop)))
  :victim-state   defenseless
  :yields         slash_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :pressure-floor humiliation 0.8
  :weight         0.3)

; ---- Blunt (3) -------------------------------------------------------------
(method beat_to_death
  :goal-fit       kill
  :requires       ((control_any (facets bludgeon)))
  :yields         blunt_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.8)

(method bludgeon
  :goal-fit       kill
  :requires       ((control_any (facets bludgeon)))
  :yields         blunt_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.9)

(method push_from_height
  :goal-fit       kill
  :yields         blunt_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.4)

; ---- Asphyxiation (5) ------------------------------------------------------
(method strangle
  :goal-fit       kill
  :victim-state   defenseless
  :yields         ligature_mark bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.6)

(method garrotte
  :goal-fit       kill
  :requires       ((control_any (facets strangle)))
  :victim-state   defenseless
  :yields         ligature_mark
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.5)

(method smother
  :goal-fit       kill
  :requires       ((control_any (facets smother)))
  :victim-state   defenseless
  :yields         bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.4)

(method hang
  :goal-fit       kill
  :requires       ((control_any (facets strangle)))
  :victim-state   defenseless
  :yields         ligature_mark
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.3)

(method neck_snap
  :goal-fit       kill
  :victim-state   defenseless
  :yields         bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     head
  :weight         0.2)

; ---- Projectile (1) --------------------------------------------------------
(method shoot
  :goal-fit       kill
  :requires       ((control_any firearm))
  :yields         puncture_wound
  :method-aux     firearm
  :terminal       kill_victim
  :wound-site     torso
  :weight         1.0)

; ---- Explosive (1) ---------------------------------------------------------
(method bomb
  :goal-fit       kill
  :requires       ((control_any explosive))
  :yields         burn_wound blunt_wound
  :method-aux     explosive
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.2)

; ---- Chemical (1) ---------------------------------------------------------
; tamper_with_substance: no inventory gate today (no poison_substance
; kind). :requires authored as documentation; lands once poison kinds exist.
(method tamper_with_substance
  :goal-fit       kill
  :requires       ((access_any ingestible_or_inhalable))
  :yields         bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.6)

; ---- Hydraulic (1) --------------------------------------------------------
(method drown
  :goal-fit       kill
  :requires       ((access_any body_of_water))
  :victim-state   defenseless
  :yields         bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.3)

; ---- Thermal (4) ----------------------------------------------------------
(method freeze
  :goal-fit       kill
  :victim-state   defenseless
  :in-season      winter
  :yields         burn_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.2)

(method immolate
  :goal-fit       kill
  :requires       ((control_any (facets burn_fuel)) (control_any (facets ignite)))
  :yields         burn_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.3)

(method arson
  :goal-fit       kill
  :requires       ((control_any (facets burn_fuel)) (control_any (facets ignite)))
  :yields         burn_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.4)

(method cook_alive
  :goal-fit       kill
  :victim-state   defenseless
  :requires       ((access_any hot_enclosure))
  :yields         burn_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.1)

; ---- Electrical (0) - electrocute retired 2026-05-26 with the
; electrical_apparatus kind. Anachronistic for most of the 1700-1897
; window anyway (mains electrification is late 1880s+); reintroduce
; with specific kinds (electric_lamp / telegraph_apparatus) when the
; setting demands.

; ---- Animal (2) - require animal substrate that doesn't exist yet ---------
; Authored for completeness; the :requires predicates are non-control
; (access to a kept animal), so without the evaluator extension they
; fire even without an animal. Drop weight low so they rarely pick.
(method unleash_animal
  :goal-fit       kill
  :requires       ((access_any dangerous_animal))
  :yields         bite_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.05)

(method unleash_insect
  :goal-fit       kill
  :requires       ((access_any venomous_insects))
  :victim-state   defenseless
  :yields         bruise
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.05)

; ---- Trap (1) -------------------------------------------------------------
(method death_trap
  :goal-fit       kill
  :requires       ((control_any tools))
  :yields         blunt_wound
  :method-aux     tools
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.2)

; ---- Indirect (2) - delegation-based --------------------------------------
; arrange_accident retired 2026-05-26 - too vague to be useful (per design
; review). push_from_height IS an arranged accident; future named
; staged-accidents (poisoning, gas-leak, carriage-collision) get explicit
; rows when authored.

; uriah_gambit: dispatch to a lethal posting. Needs has_authority_over
; (not gated in PR-3d) - authored anyway with low weight.
(method uriah_gambit
  :goal-fit       kill
  :requires       ((has_authority_over))
  :yields         puncture_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.1)

; hire_assassin: needs money + underworld contact - both absent today.
; Authored for substrate completeness, low weight.
(method hire_assassin
  :goal-fit       kill
  :yields         puncture_wound
  :method-aux     _
  :terminal       kill_victim
  :wound-site     torso
  :weight         0.05)

; ============================================================================
; NON-KILL family (7 methods)
; ============================================================================

; ---- steal (2) ------------------------------------------------------------
(method opportunist_theft
  :goal-fit       steal
  :method-aux     _
  :terminal       transfer_property
  :weight         1.0)

(method embezzle
  :goal-fit       steal
  :requires       ((has_authority_over))
  :method-aux     _
  :terminal       transfer_property
  :weight         0.4)

; ---- expose (2) -----------------------------------------------------------
(method confront_publicly
  :goal-fit       expose
  :method-aux     _
  :terminal       publish_secret
  :weight         0.6)

(method anonymous_letter
  :goal-fit       expose
  :requires       ((can_write))
  :method-aux     _
  :terminal       publish_secret
  :weight         0.4)

; ---- coerce (2) -----------------------------------------------------------
(method threaten_violence
  :goal-fit       coerce
  :method-aux     _
  :terminal       silence_coerce
  :weight         0.7)

(method blackmail
  :goal-fit       coerce
  :method-aux     _
  :terminal       silence_coerce
  :weight         0.5)

; ---- hurt (1) -------------------------------------------------------------
(method beating
  :goal-fit       hurt
  :yields         bruise
  :method-aux     _
  :terminal       harm_non_lethal
  :wound-site     torso
  :weight         1.0)

; ============================================================================
; PR-3d new goal-label family (5 methods, one per new goal)
; ============================================================================

; humiliate goal -> public_slight terminal (witness-propagated humiliation)
(method public_humiliation
  :goal-fit       humiliate
  :method-aux     _
  :terminal       public_slight
  :pressure-floor humiliation 0.6
  :weight         1.0)

; discredit goal -> spread_rumour terminal (witness-propagated false story)
(method spread_rumour
  :goal-fit       discredit
  :method-aux     _
  :terminal       spread_rumour
  :pressure-floor rivalry_pressure 0.5
  :weight         1.0)

; bribe goal -> pay_off terminal (cash transfer; PR-3d ships as mint-only stub)
(method offer_bribe
  :goal-fit       bribe
  :method-aux     _
  :terminal       pay_off
  :weight         1.0)

; frame goal -> plant_evidence terminal (yields planted on framed party)
(method plant_evidence
  :goal-fit       frame
  :yields         blood_stain
  :method-aux     _
  :terminal       plant_evidence
  :wound-site     torso
  :weight         1.0)

; seduce goal -> consummate terminal (reciprocal lover beliefs)
(method seduction
  :goal-fit       seduce
  :method-aux     _
  :terminal       consummate
  :weight         1.0)
