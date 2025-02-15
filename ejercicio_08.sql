with averia as (
  select distinct
    ivr_id
  from keepcoding.ivr_modules
  where upper(trim(module_name)) = 'AVERIA_MASIVA'
)
select 
    calls.ivr_id,
    case
      when ave.ivr_id is not null then 1
      else 0
    end as averia_masiva
from keepcoding.ivr_calls calls
left join averia ave
on calls.ivr_id = ave.ivr_id
order by calls.ivr_id;


       