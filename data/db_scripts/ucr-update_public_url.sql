--
-- Update the public url via SQL as the server.properties file change
-- is not being picked up.

update ur_server_properties
  set current_value = 'http://ucrdr.demo:81'
  where name = 'public.url'
;
