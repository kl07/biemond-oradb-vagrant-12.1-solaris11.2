node 'dbsol.example.com'  {
  include oradb_os
  include oradb_12c
  #include oradb_init
}

# operating settings for Database & Middleware
class oradb_os {

  # /etc/inet/hosts
  host{'solaris-vagrant':
    ensure => absent,
  }

  # /etc/inet/hosts
  host{'dbsol.example.com':
    ip           => "10.10.10.10",
    host_aliases => 'dbsol',
    require      => Host['solaris-vagrant'],
  }
  # /etc/inet/hosts
  host{'localhost':
    ip           => "127.0.0.1",
    host_aliases => 'loghost,localhost.localdomain,localhost4,localhost4.localdomain4',
    require      => Host['solaris-vagrant'],
  }

  # # /etc/hosts
  # exec { "remove localhost":
  #   command => "/usr/bin/sed -e '/'127.0.0.1'/ d' /etc/hosts > /tmp/hosts.tmp && mv /tmp/hosts.tmp /etc/hosts",
  # }

  # exec { "add localhost":
  #   command => "/bin/echo '127.0.0.1 ${fqdn} ${hostname} localhost loghost' >> /etc/hosts",
  #   require => Exec["remove localhost"],
  # }

  $groups = ['oinstall','dba' ,'oper' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 500,
    gid         => 'dba',
    groups      => $groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => "/export/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group[$groups],
    managehome  => true,
  }

  $install  = "pkg:/group/prerequisite/oracle/oracle-rdbms-server-12-1-preinstall"

  package { $install:
    ensure  => present,
  }

  $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

  exec { "projadd group.dba":
    command => "projadd -U oracle -G dba -p 104 group.dba",
    require => User["oracle"],
    unless  => "projects -l | grep -c group.dba",
    path    => $execPath,
  }

  exec { "usermod oracle":
    command => "usermod -K project=group.dba oracle",
    require => [User["oracle"],Exec["projadd group.dba"],],
    path    => $execPath,
  }

  exec { "projmod max-shm-memory":
    command => "projmod -sK 'project.max-shm-memory=(privileged,4G,deny)' group.dba",
    require => [User["oracle"],Exec["projadd group.dba"],],
    path    => $execPath,
  }

  exec { "projmod max-sem-ids":
    command     => "projmod -sK 'project.max-sem-ids=(privileged,100,deny)' group.dba",
    require     => Exec["projadd group.dba"],
    path        => $execPath,
  }

  exec { "projmod max-shm-ids":
    command     => "projmod -s -K 'project.max-shm-ids=(privileged,100,deny)' group.dba",
    require     => Exec["projadd group.dba"],
    path        => $execPath,
  }

  exec { "projmod max-sem-nsems":
    command     => "projmod -sK 'process.max-sem-nsems=(privileged,256,deny)' group.dba",
    require     => Exec["projadd group.dba"],
    path        => $execPath,
  }

  exec { "projmod max-file-descriptor":
    command     => "projmod -sK 'process.max-file-descriptor=(basic,65536,deny)' group.dba",
    require     => Exec["projadd group.dba"],
    path        => $execPath,
  }

  exec { "projmod max-stack-size":
    command     => "projmod -sK 'process.max-stack-size=(privileged,32MB,deny)' group.dba",
    require     => Exec["projadd group.dba"],
    path        => $execPath,
  }

  exec { "ipadm smallest_anon_port tcp":
    command     => "ipadm set-prop -p smallest_anon_port=9000 tcp",
    path        => $execPath,
  }
  exec { "ipadm smallest_anon_port udp":
    command     => "ipadm set-prop -p smallest_anon_port=9000 udp",
    path        => $execPath,
  }
  exec { "ipadm largest_anon_port tcp":
    command     => "ipadm set-prop -p largest_anon_port=65500 tcp",
    path        => $execPath,
  }
  exec { "ipadm largest_anon_port udp":
    command     => "ipadm set-prop -p largest_anon_port=65500 udp",
    path        => $execPath,
  }

  exec { "ulimit -S":
    command => "ulimit -S -n 4096",
    path    => $execPath,
  }

  exec { "ulimit -H":
    command => "ulimit -H -n 65536",
    path    => $execPath,
  }

}

class oradb_12c {
  require oradb_os

    oradb::installdb{ '12.1.0.1-solaris-x86-64':
      version                => '12.1.0.1',
      file                   => 'solaris.x64_12cR1_database',
      databaseType           => 'EE',
      oracleBase             => hiera('oracle_base_dir'),
      oracleHome             => hiera('oracle_home_dir'),
      userBaseDir            => '/home',
      bashProfile            => false,
      user                   => hiera('oracle_os_user'),
      group                  => hiera('oracle_os_group'),
      group_install          => 'oinstall',
      group_oper             => 'oper',
      zipExtract             => true,
      downloadDir            => hiera('oracle_download_dir'),
      remoteFile             => false,
      puppetDownloadMntPoint => hiera('oracle_source'),
    }

    oradb::net{ 'config net8':
      oracleHome   => hiera('oracle_home_dir'),
      version      => '12.1',
      user         => hiera('oracle_os_user'),
      group        => hiera('oracle_os_group'),
      downloadDir  => hiera('oracle_download_dir'),
      require      => Oradb::Installdb['12.1.0.1-solaris-x86-64'],
    }

    oradb::listener{'start listener':
      oracleBase   => hiera('oracle_base_dir'),
      oracleHome   => hiera('oracle_home_dir'),
      user         => hiera('oracle_os_user'),
      group        => hiera('oracle_os_group'),
      action       => 'start',
      require      => Oradb::Net['config net8'],
    }

    oradb::database{ 'oraDb':
      oracleBase              => hiera('oracle_base_dir'),
      oracleHome              => hiera('oracle_home_dir'),
      version                 => '12.1',
      user                    => hiera('oracle_os_user'),
      group                   => hiera('oracle_os_group'),
      downloadDir             => hiera('oracle_download_dir'),
      action                  => 'create',
      dbName                  => hiera('oracle_database_name'),
      dbDomain                => hiera('oracle_database_domain_name'),
      sysPassword             => hiera('oracle_database_sys_password'),
      systemPassword          => hiera('oracle_database_system_password'),
      dataFileDestination     => "/oracle/oradata",
      recoveryAreaDestination => "/oracle/flash_recovery_area",
      characterSet            => "AL32UTF8",
      nationalCharacterSet    => "UTF8",
      emConfiguration         => 'NONE',
      memoryTotal             => "800",
      sampleSchema            => 'FALSE',
      databaseType            => "MULTIPURPOSE",
      require                 => Oradb::Listener['start listener'],
    }

    oradb::dbactions{ 'start oraDb':
      oracleHome              => hiera('oracle_home_dir'),
      user                    => hiera('oracle_os_user'),
      group                   => hiera('oracle_os_group'),
      action                  => 'start',
      dbName                  => hiera('oracle_database_name'),
      require                 => Oradb::Database['oraDb'],
    }

    oradb::autostartdatabase{ 'autostart oracle':
      oracleHome              => hiera('oracle_home_dir'),
      user                    => hiera('oracle_os_user'),
      dbName                  => hiera('oracle_database_name'),
      require                 => Oradb::Dbactions['start oraDb'],
    }

}

class oradb_init {
  require oradb_12c

  init_param { 'SPFILE/OPEN_CURSORS:*@orcl':
    ensure => 'present',
    value  => '300',
  }

  init_param { 'SPFILE/processes:*@orcl':
    ensure => 'present',
    value  => '600',
  }

  init_param{'SPFILE/job_queue_processes:*@orcl':
    ensure  => present,
    value   => '2',
    require => [Init_param['SPFILE/OPEN_CURSORS:*@orcl'],
                Init_param['SPFILE/processes:*@orcl'],],
  }

  db_control{'orcl restart':
    ensure                  => 'running', #running|start|abort|stop
    instance_name           => hiera('oracle_database_name'),
    oracle_product_home_dir => hiera('oracle_home_dir'),
    os_user                 => hiera('oracle_os_user'),
    refreshonly             => true,
    subscribe               => Init_param['SPFILE/job_queue_processes:*@orcl'],
  }

}