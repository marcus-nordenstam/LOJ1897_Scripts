; ----------------------------------------------------------------------------
; occupation_domains.hs - the `domain` a job CONFERS competence in, as authored
; config (a (define-table ...), like businesses / cornerstone_businesses). Loaded
; from historical/tables/ into the .hse catalog; read by derive_skills (C++) via
; hse_table_lookup - there is NO bespoke C++ parser or derived map (the old
; s_skill_grants was removed).
;
;   job     - the job kind, [k job <leaf>] (the KEY; matches the worker's job
;             object kind). Under the org_pos > job tree.
;   domain  - a `domain` leaf (a bare atom, resolved to the domain kind by the
;             reader). S4 derive_skills grows {@self skilled_in <domain>} from
;             tenure in this job.
;
; A job NOT listed here confers no domain skill (professor's competence is his
; earned degree, not the post; lower trades / service confer none).
; ----------------------------------------------------------------------------

(define-table occupation_domains
  (fields job                       domain)
  (record [k job banker]            accountancy)
  (record [k job industrialist]     engineering)
  (record [k job landlord]          commerce)
  (record [k job merchant]          commerce)
  (record [k job proprietor]        commerce)
  (record [k job solicitor]         law)
  (record [k job physician]         medicine)
  (record [k job surgeon]           medicine)
  (record [k job apothecary]        medicine)
  (record [k job priest]            theology)
  (record [k job principal]         secondary_school_curriculum)
  (record [k job editor]            literature)
  (record [k job journalist]        literature)
  (record [k job printer]           literature)
  (record [k job teacher]           secondary_school_curriculum)
  (record [k job engineer]          engineering)
  (record [k job clerk]             accountancy)
  (record [k job typist]            accountancy)
  (record [k job house_agent]       commerce)
  (record [k job librarian]         literature)
  (record [k job curator]           history)
  (record [k job farmer]            husbandry)
  (record [k job gardener]          husbandry)
  (record [k job nurse]             medicine)
  (record [k job jockey]            husbandry))
