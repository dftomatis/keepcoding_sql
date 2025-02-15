select 
    calls.ivr_id,
    case
      when exists (select 
                    phone_number 
                  from keepcoding.ivr_calls
                  where phone_number = calls.phone_number
                  and start_date >= timestamp_sub(calls.start_date, interval 24 hour)
                  and start_date < calls.start_date) then 1
      else 0
    end as call_24_hours_before,
    case
      when exists (select 
                    phone_number 
                  from keepcoding.ivr_calls
                  where phone_number = calls.phone_number
                  and start_date <= timestamp_add(calls.end_date, interval 24 hour)
                  and start_date > calls.end_date) then 1
      else 0
    end as call_24_hours_later
from keepcoding.ivr_calls calls
;
