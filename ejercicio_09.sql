with customer_ok as (
  select distinct
    ivr_id
  from keepcoding.ivr_steps
  where upper(trim(step_name)) = 'CUSTOMERINFOBYPHONE.TX'
  and upper(trim(step_result)) = 'OK'
)
select 
    calls.ivr_id,
    case
      when cus.ivr_id is not null then 1
      else 0
    end as customer_info
from keepcoding.ivr_calls calls
left join customer_ok cus
on calls.ivr_id = cus.ivr_id
order by calls.ivr_id;


       