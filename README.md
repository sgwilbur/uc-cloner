#### UC Cloner

Simple proof of concept of how to perform the cloning of an existing UrbanCode Deploy and Release environment for setting up staging/testing areas.

### Caveats

This example is very limited in scope and functionality but is a practical implementation for reference on Linux platforms. The intent is to provide a minimum viable product to show the end to end process.

### Pre-Requiste Setup

This example was done on a single machine where I built out a UCD/UCR setup, integrated the two, and configured them to be functional. This was all done in my case on Ubuntu Trusty with MySQL 5.7, using the default-jre-headless package. Used `rsa-keygen` to create a pub/private key and configured so it could login to itself via ssh without prompt.

 I created the initial machine(uc1) in Vagrant and then manually cloned to create another machine(uc2) when I was ready to perform the clone. So after creating the target machine I did the required changes to re-initialize the MAC address and configure a new IP address for them to co-exist on the same network and communicate with each other.

### Usage

Source server:

    ./full_backup.sh

If no shared directory is used, you must then sync your data dir between machines:

    ./sync_data_dir.sh

Target server:

    ./full_restore.sh ${data_dir}/F20140404-2113/

During the restore you are prompted to run some SQL against the UCR database, and a properties file replacement script against the new files that have been layed down.

### Next Steps:

Still focusing on only Linux targets, provide a more robust skeleton that can run in a slightly more complex environment.

  * Incremental backups
  * add pluggables for different databases
  * pluggable filesystem management solution( rsync is only on *nix, what to use for Windows? AIX? )

#### Reference:

 * [ibm.com - What is the best way to clone the IBM Urban Code Deploy server and database for testing upgrades?](http://www-01.ibm.com/support/docview.wss?uid=swg21694427)
