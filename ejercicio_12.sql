create table `keepcoding.ivr_sumary` as
with ivr_base_all as (
select
  ivr_id,
  phone_number,
  ivr_result,
  vdn_label,
  start_date,
  start_date_id,
  end_date,
  end_date_id,
  total_duration,
  customer_segment,
  ivr_language,
  steps_module,
  module_aggregation,
  module_sequece_module,
  module_name,
  module_duration,
  module_result,
  module_sequece_step,
  step_name,
  step_result,
  step_description_error,
  document_type,
  document_identification,
  customer_phone,
  billing_account_id,
  row_number() over (partition by cast(ivr_id as string) order by start_date desc) as rn
from 
keepcoding.ivr_detail
),
ivr_base as (
  select 
    *
  from ivr_base_all
  where rn = 1
),
vdn_aggregation as (
  select
    ivr_id,
    case
      when upper(trim(vdn_label)) like 'ATC%' then 'FRONT'
      when upper(trim(vdn_label)) like 'TECH%' then 'TECH'
      when upper(trim(vdn_label)) like 'ABSORPTION%' then 'ABSORPTION'
      else 'RESTO'
    end as vdn_aggregation
  from `keepcoding.ivr_calls`
),
docs as (
  select 
    ivr_id,
    document_type,
    document_identification,
    row_number() over (partition by cast(ivr_id as string) order by step_sequence desc) as rn
  from keepcoding.ivr_steps
  where document_type != 'UNKNOWN'
  and document_identification != 'UNKNOWN'
),
last_doc as (
  select 
    ivr_id,
    document_type,
    document_identification,
  from docs
  where rn = 1
),
documents as (
  select 
      ivr.ivr_id,
      coalesce(doc.document_type, 'UNKNOWN') as document_type,
      coalesce(doc.document_identification, 'UNKNOWN') as document_identification
  from keepcoding.ivr_calls ivr
  left join last_doc doc
  on ivr.ivr_id = doc.ivr_id
),
phones as (
  select distinct
    ivr_id,
    customer_phone
  from keepcoding.ivr_steps
  where customer_phone != 'UNKNOWN'
),
customer_phone as(
  select 
    ivr.ivr_id,
    coalesce(pho.customer_phone, 'UNKNOWN') as phone
  from keepcoding.ivr_calls ivr
  left join phones pho
  on ivr.ivr_id = pho.ivr_id
  order by phone desc
),
accounts as (
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
),
billing_account as(
  select 
    calls.ivr_id,
    coalesce(acc.billing_account_id, 'UNKNOWN') as account_id,
  from keepcoding.ivr_calls calls
  left join account_unique acc
  on calls.ivr_id = acc.ivr_id
),
averia as (
  select distinct
    ivr_id
  from keepcoding.ivr_modules
  where upper(trim(module_name)) = 'AVERIA_MASIVA'
),
masiva_lg as (
  select 
    calls.ivr_id,
    case
      when ave.ivr_id is not null then 1
      else 0
    end as averia_masiva
  from keepcoding.ivr_calls calls
  left join averia ave
  on calls.ivr_id = ave.ivr_id
),
customer_ok as (
  select distinct
    ivr_id
  from keepcoding.ivr_steps
  where upper(trim(step_name)) = 'CUSTOMERINFOBYPHONE.TX'
  and upper(trim(step_result)) = 'OK'
),
info_by_phone as (
  select 
    calls.ivr_id,
    case
      when cus.ivr_id is not null then 1
      else 0
    end as info_by_phone_lg
  from keepcoding.ivr_calls calls
  left join customer_ok cus
  on calls.ivr_id = cus.ivr_id
),
info_by_dni as (
  select 
    calls.ivr_id,
    case
      when cus.ivr_id is not null then 1
      else 0
    end as info_by_dni_lg
  from keepcoding.ivr_calls calls
  left join customer_ok cus
  on calls.ivr_id = cus.ivr_id
),
repeat_call as (
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
)
select 
  base.ivr_id,
  base.phone_number,
  base.ivr_result,
  base.vdn_label,
  base.start_date,
  base.start_date_id,
  base.end_date,
  base.end_date_id,
  base.total_duration,
  base.customer_segment,
  base.ivr_language,
  base.steps_module,
  base.module_aggregation,
  base.module_sequece_module,
  base.module_name,
  base.module_duration,
  base.module_result,
  base.module_sequece_step,
  base.step_name,
  base.step_result,
  base.step_description_error,
  vdn.vdn_aggregation,
  documents.document_type,
  documents.document_identification,
  customer_phone.phone as customer_phone,
  billing_account.account_id,
  masiva_lg.averia_masiva,
  info_by_phone.info_by_phone_lg,
  info_by_dni.info_by_dni_lg,
  repeat_call.call_24_hours_before,
  repeat_call.call_24_hours_later
from ivr_base base
left join vdn_aggregation vdn
on base.ivr_id = vdn.ivr_id
left join documents
on base.ivr_id = documents.ivr_id
left join customer_phone
on base.ivr_id = customer_phone.ivr_id
left join billing_account
on base.ivr_id = billing_account.ivr_id
left join masiva_lg
on base.ivr_id = masiva_lg.ivr_id
left join info_by_phone
on base.ivr_id = info_by_phone.ivr_id
left join info_by_dni
on base.ivr_id = info_by_dni.ivr_id
left join repeat_call
on base.ivr_id = repeat_call.ivr_id
;