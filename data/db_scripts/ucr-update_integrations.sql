--

-- Disable ucr integration
-- tables ur_integration_provider
-- select id, name, prop_sheet_id from ur_integration_provider where name = "uc1.prod";
-- this will give you the integration id
-- from the prop_sheet_id you can find your properties
-- update your url property


-- select id, name, prop_sheet_id, ghosted_date from ur_integration_provider
--   where
--     name = 'ucd.demo' and ghosted_date = 0
-- ;

-- All active integrations
-- select id from ur_integration_provider where ghosted_date = 0
-- ;
--
-- -- Get all properties for a integration by name
-- select id, name, value, prop_sheet_id from ps_prop_value
-- where
-- prop_sheet_id = (select prop_sheet_id from ur_integration_provider
--   where name = 'ucd.demo' and ghosted_date = 0)
--
-- ;
--
-- -- Update the UCD Plugin Integration host by name
-- update ps_prop_value
--   set deployHostName = 'http://ucddr.demo', name = 'ucddr.demo'
--   where
--     prop_sheet_id = (select prop_sheet_id from ur_integration_provider
--       where name = 'ucd.demo' and ghosted_date = 0)
-- ;

update ps_prop_value
  set  value = 'http://ucddr.demo'
  where
    name = 'deployHostName'
    and
    prop_sheet_id = (select prop_sheet_id from ur_integration_provider
      where name = 'ucd.demo' and ghosted_date = 0)
;

update ur_integration_provider
  set name = 'ucddr.demo'
  where
    name = 'ucd.demo' and ghosted_date = 0;
