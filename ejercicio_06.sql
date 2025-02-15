with phones as (
  select distinct
    ivr_id,
    customer_phone
  from keepcoding.ivr_steps
  where customer_phone != 'UNKNOWN'
)
select 
    ivr.ivr_id,
    coalesce(pho.customer_phone, 'UNKNOWN') as phone
from keepcoding.ivr_calls ivr
left join phones pho
on ivr.ivr_id = pho.ivr_id
order by phone desc;


       