# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Uses some helper Vagrant plugins, that can be added locally pretty easy.
#  $ vagrant plugin install <plugin>
# optional:
#  * vagrant-cachier - to cache where possible

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # vagrant-cachier plugin defaults: http://fgrehm.viewdocs.io/vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  # Local variables
  media_host = 'http://192.168.1.65:8001'

  # use a single key for all hosts
  config.ssh.insert_key = false
  ips = [
    '192.168.35.20',
    '192.168.35.21',
    '192.168.35.22',
    '192.168.35.23',
    '192.168.35.24' ]

  # box to use
  config.vm.box = "ubuntu/trusty64"

  # ansible configuration
  ansible_playbook_path = '~/workspaces/ansible-all-the-things'

  # ucdata will be the mysql and nfs server
  config.vm.define "ucdata", primary: true, autostart: true do |uc|
    uc.vm.hostname = 'ucdata.demo'
    uc.vm.network :private_network, ip: "#{ips[0]}"

    uc.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--ioapic", "on"  ]
      vb.customize ["modifyvm", :id, "--cpus"  , "2"   ]
      vb.customize ["modifyvm", :id, "--memory", "2048"]
    end # vm provider

    uc.vm.provision :ansible do |ansible|

      ansible.playbook = "playbooks/base.yml"
      ansible.inventory_path = "./hosts"
      ansible.extra_vars = {
        ansible_ssh_user: 'vagrant',
        ansible_sudo: 'true',
        ntp_server: "pool.ntp.org",
      }
      ansible.limit = 'ucdata'
    end # provision

  end # vm define ucdata

  # Loop over our base machines
  (1..4).each do |i|

    config.vm.define "uc#{i}", primary: true, autostart: true do |uc|
      uc.vm.hostname = "uc#{i}.demo"
      uc.vm.network :private_network, ip: "#{ips[i]}"

      uc.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--ioapic", "on"  ]
        vb.customize ["modifyvm", :id, "--cpus"  , "2"   ]
        vb.customize ["modifyvm", :id, "--memory", "2048"]
      end # vm provider

      if i < 4
        next
      end

      uc.vm.provision :ansible do |ansible|
        ansible.playbook = "playbooks/base.yml"
        ansible.inventory_path = "./hosts"
        ansible.extra_vars = {
          ansible_ssh_user: 'vagrant',
          ansible_sudo: 'true',
          ntp_server: "pool.ntp.org",
        }
        ansible.limit = "uc*"
      end # provision
  end # vm define

  end # loop over creating uc vms

end # Vagrant.configure
