; ----------------------------------------------------------------------------
; place_names.hsc - names for orgs / businesses (EDITABLE).
;
; Model: BUILDINGS have ADDRESSES (a number on their street, from geography);
; ORGS / businesses have NAMES, drawn from this file. A building is surfaced by
; its sole org's name when it houses exactly ONE org (a pub, a shop, a club),
; or by a named-residence name (mansion / chateau / manor); otherwise it is
; surfaced as "<address> [k <kind>]" e.g. "14 Victoria Street [k cottage]".
;
; Two forms:
;
;   (named-club "<name>" :kind social|athletic :founded <year> :class <band>)
;       A SPECIFIC, pre-placed club instance. Founded in <year>; its clientele
;       sits in class <band> (lower|middle|upper). Order = listing order.
;
;   (names <building-kind> "Name A" "Name B" ...)
;       A name POOL. A procedurally-spawned building of <kind> that houses a
;       single org draws the next unused name; when the pool runs dry it falls
;       back to the address form.
; ----------------------------------------------------------------------------

; === The five named social clubs (gentlemen's / society clubs of Port Christie)
; Pre-placed institutions, each with its own clientele and founding date.

; "The people who own the island." Old island families, retired diplomats,
; senior barristers, merchant dynasties; a Georgian waterfront building. Oldest
; and most prestigious - membership inherited as often as earned.
(named-club "The Albion Club"     :kind social :founded 1705 :class upper)

; "The people who built the island." Shipowners, naval officers, harbour
; masters, explorers, industrialists. Practical aristocrats; nautical charts and
; model ships, an excellent bar.
(named-club "The Mariner's Club"  :kind social :founded 1707 :class upper)

; "The people who explain the island." Clergy, academics, judges, newspaper
; editors, senior civil servants. The intellectual club: an extensive library,
; a lecture hall, culture over wealth. (Renamed from St. Clement's Society.)
(named-club "The St-Revi Society" :kind social :founded 1712 :class upper)

; "The people who finance the island." The new-money club, founded in a
; financial boom: new financiers, joint-stock company promoters, colonial and
; international investors, stockbrokers. The old clubs dismiss it as money
; without history.
(named-club "Meridian House"      :kind social :founded 1827 :class upper)

; "The people who will change the island." The newest, most fashionable club,
; for those the old institutions would not have admitted: self-made
; industrialists, engineers, journalists, architects, younger radical
; politicians, professional men. Less wealth, more influence over the future.
(named-club "The Foundry"         :kind social :founded 1839 :class middle)

; === Name pools for procedurally-named businesses ===========================
; Extend these freely. A building of the kind that houses a single org draws
; the next unused name.

(names pub
  "The Lion Inn" "The Anchor" "The Crown" "The Ship Inn" "The Smugglers Rest"
  "The Fishermans Arms" "The Kings Head" "The Globe" "The Albion Tavern"
  "The Harbour Lights")

(names athletic_clubhouse
  "The Corinthian Club" "Saltcombe Rowing Club" "The Turf Club"
  "Port Christie Cricket Club")

; Residences with names (mansion / chateau / manor) - pre-placed grand houses.
(names mansion
  "Wexford Hall" "Calloway House" "The Cedars" "Ashgrove Manor")
