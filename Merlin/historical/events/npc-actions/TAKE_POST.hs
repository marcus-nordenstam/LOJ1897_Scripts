; ----------------------------------------------------------------------------
; take_post - the clerical WRITE act of the labour market (the thinks live in
; recruit_think.hs / job_search_think.hs). Pen-changes-paper: a document is
; filed / stamped. An org is a mental-only object and never an act participant -
; every participant is paper or people.
;
; SEEKER: take up the offered post - write his own row onto the wage book (?jk from the
; still-running apply_for). Reading his row back (tup_read_book) realizes employment.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self TAKE_POST ?art ?jk}
  (duration 15)
  (effects
    ; The offered job kind must ride the still-running apply_for onto the roster row.
    (check ?jk)
    (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
    ; The articles MUST name an employee_register, else the roster write below is a
    ; silent no-op and the worker never enrolls (0 rostered).
    (check ?reg)
    (write-doc-record [k employee_register] ?reg
        (worker @self) (job ?jk) (level [k trainee]))
    (set-outcome {@self TAKE_POST ?art ?jk} succ)))
