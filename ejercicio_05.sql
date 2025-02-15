with docs as (
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
)
select 
    ivr.ivr_id,
    coalesce(doc.document_type, 'UNKNOWN') as document_type,
    coalesce(doc.document_identification, 'UNKNOWN') as document_identification
from keepcoding.ivr_calls ivr
left join last_doc doc
on ivr.ivr_id = doc.ivr_id;

       