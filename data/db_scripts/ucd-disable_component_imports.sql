--
-- Disable all Component import polling

update ds_component
  set import_automatically = 'N';
