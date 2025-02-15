with accounts as (
  select
    ivr_id,
    billing_account_id,
    row_number() over (partition by cast(ivr_id as string) order by step_sequence desc) as rn
  from keepcoding.ivr_steps
  where billing_account_id != 'UNKNOWN'
),
account_unique as (
  select
    ivr_id,
    billing_account_id
  from accounts
  where rn = 1
)
select 
    calls.ivr_id,
    coalesce(acc.billing_account_id, 'UNKNOWN') as account_id,
from keepcoding.ivr_calls calls
left join account_unique acc
on calls.ivr_id = acc.ivr_id
order by account_id asc;


       