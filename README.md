## Oracle Solaris 11.2 with Oracle Database 12.1.0.1

The reference implementation of https://github.com/biemond/biemond-oradb
optimized for linux, solaris

### Software ( 12.1.0.1 )
- solaris.x64_12cR1_database_1of2.zip
- solaris.x64_12cR1_database_2of2.zip

### Vagrant
Update the vagrant /software share to your local binaries folder

Startup the box
- vagrant up dbsol

Login
- vagrant ssh dbsol

Set default kernel parameters for root & puppet
- sudo projmod -sK "project.max-shm-memory=(privileged,3G,deny)" user.root
- sudo projmod -sK 'project.max-sem-ids=(privileged,100,deny)' user.root
- sudo projmod -sK 'project.max-shm-ids=(privileged,100,deny)' user.root
- sudo projmod -sK 'process.max-sem-nsems=(privileged,256,deny)' user.root
- sudo projmod -sK 'process.max-file-descriptor=(basic,65536,deny)' user.root
- sudo projmod -sK 'process.max-stack-size=(privileged,32MB,deny)' user.root

Set swap and startup puppet
- sudo su -
- zfs set volsize=6g rpool/swap
- /opt/csw/bin/puppet apply /vagrant/puppet/manifests/site.pp --trace --verbose --hiera_config /vagrant/puppet/hiera.yaml --modulepath /vagrant/puppet/modules

### Port forwarding
- 1521

### Accounts
- root password vagrant123
- vagrant password 1vagrant
- oracle password oracle

### extra, speed up

site.pp
- set zipExtract = false on oradb::installdb

on guest
- sudo mkdir -p /var/tmp/install
- sudo chmod 0777 /var/tmp/install

on host
- scp -P 2222 ~/software/solaris.x64_12cR1_database_*  vagrant@127.0.0.1:/var/tmp/install

on guest
- unzip -o /var/tmp/install/solaris.x64_12cR1_database_1of2.zip -d /var/tmp/install/solaris.x64_12cR1_database
- unzip -o /var/tmp/install/solaris.x64_12cR1_database_2of2.zip -d /var/tmp/install/solaris.x64_12cR1_database
- chmod -R 0777 /var/tmp/install/solaris.x64_12cR1_database

