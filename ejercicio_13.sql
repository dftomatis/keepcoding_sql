create function `keepcoding`.clean_integer(value int64) 
returns int64 as (
  coalesce(value, -999999)
);