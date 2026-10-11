; The woman of the house owes her household its meal hours, a standing duty.
(think household-duty
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self gender [k female]}
    (role ?household [k household] {@self member-of ?household}
      (effects (maintain-belief {@self duty-to ?household set-mealtimes})))))
