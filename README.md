
## Multi-Server HA Backup and Restore

Leveraging the techniques in [uc-cloner]() to clone a simple linux server to another linux server is pretty straight forward. However the complexity involved in trying to apply this technique in an automated way to multiple machines in a coordinated way requires a bit more complexity than we would like to build into a set of Bash scripts.

For this example, I have implemented a reference process in Ansible to perform the required steps. Again this is done with linux only hosts and using a simple shared storage provided by Vagrant. But for the purposes of this example the fact that all machines have the same shared filesystem mounted in the same folder structure on each machine is the key point here.


#### Requirements and Assumptions

UrbanCode Deploy:
 * UCD Servers are running as services named `ibm-ucd-server` using the provided init scripts
 * UCD is using a shared filesystem for `appdata` at `/vagrant/data/ucd${env_name}/...`


UrbanCode Release:
 * UCR Servers are running as services named 'ibm-release-server'
 * Init script has added for UCR as none exists out of the box
 * Using a shared filesystem for application data at at `/vagrant/data/ucr${env_name}/...`
 * Add JAVA_HOME to server.startup script to ensure plugins will run ( Defect that seems to still be there...)



#### Ad-hoc commands

    ansible uc-primary-servers -i hosts -become -m service -a "name=ibm-release-server state=started"
    ansible uc-primary-servers -i hosts -become -m service -a "name=ibm-ucd-server state=started"
