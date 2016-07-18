#### UC Cloner

Simple proof of concept of how to perform the cloning of an existing UrbanCode Deploy and Release environment for setting up staging/testing areas.

### Caveats

This example is very limited in scope and functionality but is a practical implementation for reference on Linux platforms. The intent is to provide a minimum viable product to show the end to end process.

### Pre-Requisite Setup

In order to setup this example you will need a working *nix environment to host the VirtualBox images and run the Ansible playbooks from. This example is not a fully bootstrapping example so you will still need to setup and configure all the products on the target machines in order to run this against the example environment. ( I may add this in the future as I have Ansible roles I am working on publishing to galaxy as well for UCD/UCR, for now this is an exercise for the reader)

Software:

 * VirtualBox
 * Vagrant
 * Ansible

Updated to leverage *Ansible* to allow for multi-host operations.

This example was done  using 5 virtual machines which I built out a UCD/UCR setup, integrated the two, and configured them to be functional. This was all done in my case on Ubuntu Trusty with MySQL 5.7, using the default-jre-headless package.

The environment consists of a *primary* and *dr* environment, where *primary* is made up of two machines `uc1` and `uc2`, *dr* is made up of two machines `uc3` and `uc4` and the fifth machine `ucdata` acts as the *mysql* and *haproxy* server.

The database server hosts 4 databases:

 * ibm_ucd01
 * ibm_ucr01
 * ibm_ucd02
 * ibm_ucr02

The load balancer is configured to host 4 urls by name and port:

  * http://ucd.demo
  * http://ucr.demo:81
  * http://ucddr.demo
  * http://ucrdr.demo:81

I created the initial clusters on (uc1 & uc2) for both UCD and UCR using the urls, installed the software on uc3 & uc4. Completed the backup of the primary environments, then used those backups to seed the dr environment and perform the required reconfigurations.

UrbanCode Deploy:
 * UCD Servers are running as services named `ibm-ucd-server` using the provided init scripts
 * UCD is using a shared filesystem for `appdata` at `/vagrant/data/ucd${env_name}/...`


UrbanCode Release:
 * UCR Servers are running as services named 'ibm-release-server'
 * Init script has added for UCR as none exists out of the box
 * Using a shared filesystem for application data at at `/vagrant/data/ucr${env_name}/...`
 * Add JAVA_HOME to server.startup script to ensure plugins will run ( Defect that seems to still be there...)

### Backup Scenarios

The backup process is pretty simple and consists of two types of backups. The complete backup and an incremental backup.

  1. Take a complete backup of an UrbanCode System(s)
  Common scenario here, that outlines the supported backup procedure as recommended in the product documentation, which requires the server to be down to perform an a complete backup.

  Should be a procedure that is completed on a regular basis, based on your infrastructure standards this could be a weekly/bi-weekly/monthly type cadence. For integrated tools, planning backups and downtimes together is logical as they can be treated as a set.

   * **UrbanCode Deploy**
      1. Stop all Deploy servers.
      1. Backups to take: (can be done in parallel)
       * Foreach server, backup `server installation` directory to capture configurations.
       * Backup `appdata` location to capture process execution logs and CodeStation artifact versions.
       * Full backup of Deploy database
      1. Start all Deploy servers.

   * **UrbanCode Release**
      1. Stop all Release servers.
      1. Backups to take: (can be done in parallel)
        * Foreach server, backup `server installation` directory to capture configuration and installed plugins.
        * Backup the shared application data
        * Full backup of the Release database.
      1. Start all Release servers.

  1. [Not Implemented] Take an incremental backup of the UrbanCode System(s)
  Requires that we have enabled binary/transaction logging on our database system, or have a vendor specific solution for logging changes that can be applied to _catch up_ a earlier version of the same database.

  This should be a very regular automated job, and should be happening every 15-30m to ensure there is limit the amount of data loss if a failure event does occur. Since these are happening very often it is less important to try and coordinate them at the same time as they should be no more than 15-30m apart in the worst case here.

   * **UrbanCode Deploy**
     1. Incremental backup event triggered.
     1. Backups to take: (Should be done in parallel)
       * Synchronize current transaction log files with offsite.
       * Synchronize current `appdata` files with backup location.
       * Foreach server, synchronize current `server installation directory` files with offsite.

   * **UrbanCode Release**
     1. Incremental backup event triggered.
     1. Backups to take: (Should be done in parallel)
      * Synchronize current transaction log files with backup location.
      * Backup shared application data
      * Foreach server, synchronize current `server installation directory` files with offsite.

### Restore Scenarios

While thinking about restoring we assume that the backup was simply performing a clone. So when we decide to restore this data to another environment we need to take into account at least two scenarios described further below where the environments will run in parallel (aka clone to test) and where this is a cold copy of production ( standard backup or source for Disaster Recovery).

 1. A complete restore targeted DR, when production fails and we need to start a DR event.
 1. [Not Implemented] A complete restore to Production, when production fails and we just want to recover.
 1. [Only implemented for DR] A complete restore to another target environment, when we want to do a full data refresh of a target environment for any other reason.

Additionally we have a variant of these scenarios for restoring incremental changes.

 1. [Not Implemented] An incremental restore to Production, in the event that we have a failure or data loss that requires we restore to our last complete backup and replay incremental changes to the point in time we desire..
 1. [Not Implemented] An incremental restore to Disaster Recovery, when we want to _catch up_ DR, either during a DR event or just as a regular part of the DR readiness plan.
 1. [Not Implemented] An incremental restore to a target environment, when we want to refresh the data in our target environment with live data from production.

## Multi-Server HA Backup and Restore

Leveraging the techniques in the original [uc-cloner/tree/simple-example](https://github.com/sgwilbur/uc-cloner/tree/simple-example) branch to clone a simple linux server to another linux server is pretty straight forward. However the complexity involved in trying to apply this technique in an automated way to multiple machines in a coordinated way requires a bit more complexity than we would like to build into a set of Bash scripts.

For this example, I have implemented a reference process in Ansible to perform the required steps. Again this is done with linux only hosts and using a simple shared storage provided by Vagrant. But for the purposes of this example the fact that all machines have the same shared filesystem mounted in the same folder structure on each machine is the key point here.


#### Backup procedure

    ansible-playbook -i hosts uc-backup.yml --extra-vars="env_name=primary ts=201607112130"


#### Restore environment

    ansible-playbook -i hosts uc-restore.yml --extra-vars="env_name=primary target_env_name=dr ts=201607142242"

#### View of the example filesystem structure

View of the generated filesystem layout that we are working out of:

    amon:backup sgwilbur$ tree -L 5
    .
    ├── dr
    │   └── F201607112210
    │       ├── ucd
    │       │   ├── appdata
    │       │   │   ├── conf
    │       │   │   ├── patches
    │       │   │   └── var
    │       │   ├── ibm_ucd02.sql
    │       │   ├── uc3
    |       │   │   ├── bin
    |       │   │   ├── conf
    │       │   │   ├── endorsed
    │       │   │   ├── extensions
    │       │   │   ├── ilmt
    │       │   │   ├── lib
    │       │   │   ├── licenses
    │       │   │   ├── native
    │       │   │   ├── notices
    │       │   │   ├── opt
    │       │   │   └── var
    │       │   └── uc4
    │       │       └── ...
    │       └── ucr
    │           ├── appdata
    │           |   ├── attachments
    │           |   └── plugins
    │           ├── ibm_ucr02.sql
    │           ├── uc3
    │           |   ├── conf -> ucrelease/conf
    │           |   ├── groovy-2.1.9
    │           |   ├── internal
    │           |   ├── logs -> server/tomcat/logs
    │           |   └── server
    │           └── uc4
    │               └── ...
    └── primary
        ├── F201607112210
        │   └── ...
        ├── F201607121045
        │   └── ...
        └── F201607130916
            └── ...

#### Ad-hoc commands

Some useful ad-hoc commands for managing environments.

    ansible uc-primary-servers -i hosts -become -m service -a "name=ibm-release-server state=started"
    ansible uc-primary-servers -i hosts -become -m service -a "name=ibm-ucd-server state=started"

#### Reference:

 * [ibm.com - What is the best way to clone the IBM Urban Code Deploy server and database for testing upgrades?](http://www-01.ibm.com/support/docview.wss?uid=swg21694427)

#### Errors

 * UCR Error after logging in - `Invalid AES key length: XXX bytes`
    Indicates the cookie being shared between UCR HA nodes is not valid.
