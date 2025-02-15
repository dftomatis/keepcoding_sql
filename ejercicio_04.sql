select
  ivr_id,
  case
    when upper(trim(vdn_label)) like 'ATC%' then 'FRONT'
    when upper(trim(vdn_label)) like 'TECH%' then 'TECH'
    when upper(trim(vdn_label)) like 'ABSORPTION%' then 'ABSORPTION'
    else 'RESTO'
  end as vdn_aggregation
from `keepcoding.ivr_calls`;
       