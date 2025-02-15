create table `keepcoding.ivr_detail` as
select 
  calls.ivr_id,
  calls.phone_number,
  calls.ivr_result,
  calls.vdn_label,
  calls.start_date,
  format_date('%Y%m%d', calls.start_date) as start_date_id,
  calls.end_date,
  format_date('%Y%m%d', calls.end_date) as end_date_id,
  calls.total_duration,
  calls.customer_segment,
  calls.ivr_language,
  calls.steps_module,
  calls.module_aggregation,
  module.module_sequece as module_sequece_module,
  module.module_name,
  module.module_duration,
  module.module_result,
  step.module_sequece as module_sequece_step,
  step.step_name,
  step.step_result,
  step.step_description_error,
  step.document_type,
  step.document_identification,
  step.customer_phone,
  step.billing_account_id
from `keepcoding.ivr_calls` calls
inner join `keepcoding.ivr_modules` module
on calls.ivr_id = module.ivr_id
inner join `keepcoding.ivr_steps` step
on module.ivr_id = step.ivr_id
and module.module_sequece = step.module_sequece;
       