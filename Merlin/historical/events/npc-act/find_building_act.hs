; ----------------------------------------------------------------------------
; find_building has NO dedicated act. The venue-discovery search (find_building.hs) decomposes
; STRAIGHT into the shared movement primitive go_to_threshold_act (npc-act/go_act.hs): find_survey
; front-parks the actor at the closest unobserved structure, where run_effect_front_park's
; mx_observe(target) teaches the building and its kind. No survey/relocate act of its own - the
; frontier is chosen by (closest-unobserved [k structure] ?region) in the think, and perception (not
; a relocate) reveals the venue. This file is intentionally body-free.
; ----------------------------------------------------------------------------
