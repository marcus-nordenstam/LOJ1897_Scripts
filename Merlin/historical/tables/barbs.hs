; ----------------------------------------------------------------------------
; barbs.hs - the insult content model, consumed by (incident-anchor ...
; /barb-ladders barb_ladders /barb-materials barb_materials /context <atom>)
; via the insult-anchor macro. An insult with no material FAILS (the
; inarticulate brood instead of quipping) - epistemics: only mock what you
; know or can see.
;
; barb_ladders: per CONTEXT, the lanes tried and their rank (= the roll
; weight among lanes with material, so repeated barbs vary but lead lanes
; dominate).
; barb_materials: per LANE, the material rows. `source` picks the general
; C++ query shape:
;   act_record  - an act record the speaker knows under `label`
;   liaison     - a known non-spousal liaison (label = the clause label)
;   repute_low  - a float belief under `threshold` ("the club's drunkard";
;                 0.5 is the population mean, 0.35 = genuinely poor repute)
;   belief_kind - a kind-valued belief equal to `value`
;   attr_kind   - a perceptible env attr equal to `value` (girth/height are
;                 obs auto-percepts - visible to anyone who has met them)
;   aspect_low / aspect_high - mirrored big-five extremes; the most extreme
;                 deviation past `threshold` within the lane wins
;   allegation  - no material needed (the sport cheat cry; quoted speech
;                 content only, never a realis belief)
; ----------------------------------------------------------------------------

(define-table barb_ladders
  (fields context          lane          rank)
  ; displaced_anger: lashing out grabs what's visible at hand.
  (record displaced_anger  appearance    3)
  (record displaced_anger  drunkard      2)
  (record displaced_anger  character     1)
  ; dispositional: the narcissist's put-down is status elevation.
  (record dispositional    origins       4)
  (record dispositional    no_standing   3)
  (record dispositional    character     2)
  (record dispositional    appearance    1)
  ; cold_contempt: voice the REASON he is despised - his moral record.
  (record cold_contempt    moral_failing 4)
  (record cold_contempt    drunkard      3)
  (record cold_contempt    scandal       2)
  (record cold_contempt    indecorum     1)
  ; revenge: throw their own dirt - "you of all people".
  (record revenge          moral_failing 6)
  (record revenge          scandal       5)
  (record revenge          drunkard      4)
  (record revenge          indecorum     3)
  (record revenge          appearance    2)
  (record revenge          character     1)
  ; rivalry_post: undercut the claim to the seat.
  (record rivalry_post     no_standing   4)
  (record rivalry_post     origins       3)
  (record rivalry_post     character     2)
  (record rivalry_post     drunkard      1)
  ; rivalry_spouse: mock the match.
  (record rivalry_spouse   scandal       4)
  (record rivalry_spouse   indecorum     3)
  (record rivalry_spouse   origins       2)
  (record rivalry_spouse   appearance    1)
  ; rivalry_sport: the cheat cry first - anyone can shout it.
  (record rivalry_sport    cheat         3)
  (record rivalry_sport    drunkard      2)
  (record rivalry_sport    appearance    1)
  ; stranger: a stranger can mock only what he can see.
  (record stranger         appearance    1))

(define-table barb_materials
  (fields lane          source      label           value                       threshold)
  (record moral_failing act_record  assault         none                        0)
  (record moral_failing act_record  jilt            none                        0)
  (record moral_failing act_record  disinherit      none                        0)
  (record scandal       liaison     lover           none                        0)
  (record drunkard      repute_low  sobriety        none                        0.35)
  (record indecorum     repute_low  decorum         none                        0.35)
  (record no_standing   repute_low  prestige        none                        0.35)
  (record origins       belief_kind class_situation [k class_situation lower]   0)
  (record appearance    attr_kind   girth           [k girth fat]               0)
  (record appearance    attr_kind   girth           [k girth thin]              0)
  (record appearance    attr_kind   height          [k height short]            0)
  (record character     aspect_low  politeness      none                        0.30)
  (record character     aspect_low  industriousness none                        0.30)
  (record character     aspect_low  orderliness     none                        0.30)
  (record character     aspect_low  compassion      none                        0.30)
  (record character     aspect_high volatility      none                        0.70)
  (record cheat         allegation  defraud         none                        0))
