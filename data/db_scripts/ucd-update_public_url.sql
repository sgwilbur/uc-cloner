--
-- Update the public url via SQL as the installed.properties file change
-- is not being picked up.

update ps_prop_value
  set value = 'http://ucddr.demo'
  where name = 'server.external.web.url'
;

update ps_prop_value
  set value = 'http://ucddr.demo'
  where name = 'server.external.user.url'
;
