--

update ds_network_relay
  set name='uc3', host='uc3'
  where name='uc1' and host='uc1';

update ds_network_relay
  set name='uc4', host='uc4'
  where name='uc2' and host='uc2';
