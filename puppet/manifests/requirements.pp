node default{

  exec { 'sudo apt update':
    path => '/bin',
  }

###Apache
    package { 'apache2':
    ensure  => present,
    }
###PHP
    package { 'php':
      ensure  => present,
    }

    package { 'libapache2-mod-php':
      ensure  => present,
      require => Package['php'],
    }
###END PHP

### Serveur DNS
package {'bind9':
  ensure => present
}

file {'/etc/bind':
  ensure => directory
}

file {'/etc/bind/named.conf.default-zones':
  source => ''
}

file {'/etc/bind/dns.zone':
  source => ''
}

file {'/etc/bind/dns.zone.inv':
  source => ''
}

file {'/etc/resolv.conf':
  source => ''
}

##################DHCP
    package { 'isc-dhcp-server':
    ensure  => present,
    }

    service { 'isc-dhcp-server':
    ensure  => running,
    require => Package['isc-dhcp-server'],
    }

    file {'/etc/dhcp/dhcpd.conf':
        ensure  => present,
        source  => '',
        require => Package['isc-dhcp-server'],
    }

    ###PHPMYADMIN
    package {'phpmyadmin':
      ensure => present
    }

    #### Postfixadmin

exec {'wget https://liquidtelecom.dl.sourceforge.net/project/postfixadmin/postfixadmin-3.3.8/PostfixAdmin%203.3.8.tar.gz':
  path    => '/usr/bin',
  cwd     => '/srv/',
  creates => '/srv/postfixadmin/index.php'
}

exec {'tar -xzf "PostfixAdmin 3.3.8.tar.gz"':
  path    => '/bin',
  cwd     => '/srv/',
  creates => '/srv/postfixadmin/index.php'
}

exec { 'sudo mv postfixadmin-* postfixadmin':
  path    => '/usr/bin',
  cwd     => '/srv/',
  creates => '/srv/postfixadmin/index.php'
}

exec { 'ln -s postfixadmin /var/www/html/postfixadmin':
  path    => '/bin',
  cwd     => '/srv/',
  creates => '/srv/postfixadmin/index.php'
}

### Postfixadmin DB

mysql::db { 'postfixdb':
  user     => 'postfixadmin',
  password => 'postfixadmin@123',
  host     => 'localhost',
  grant    => ['ALL'],
}

file {'/srv/postfixadmin/templates_c':
  ensure => directory,
  owner  => 'www-data',
  mode   => '0755'
}

file {'/srv/postfixadmin/config.local.php':
  ensure  => present,
  require => File['/srv/postfixadmin'],
  source  => ''
}

###Postfix 

package { 'postfix-mysql':
  ensure  => present,
}





###Apache services
    service { 'apache2':
      ensure  => running,
      require => Package['apache2'],
    }

    file{ '/var/www':
        ensure  => directory,
        require => Package['apache2'],
    }



}
