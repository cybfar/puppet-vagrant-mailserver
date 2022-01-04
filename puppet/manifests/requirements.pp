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

file {'/etc/postfix/main.cf':
  ensure => present,
  source => '/vagrant/puppet/files/postfix/main.cf'
}

file {'/etc/postfix/master.cf':
  ensure => present,
  source => '/vagrant/puppet/files/postfix/master.cf'
}

service { 'postfix':
  ensure  => running,
}

group { 'vhosts':
  ensure => present,
  gid    => 5000,
}

user { '':
  ensure => present,
  uid    => '5000',
  home   => '/var/mail/vhosts',
  shell  => '/bin/false',
  groups => ['vhosts'],
}

### Dovecot

package {'dovecot-imapd':
  ensure => present
}
package {'dovecot-mysql':
  ensure => present
}
package {'dovecot-core':
  ensure => present
}

file {'/etc/dovecot/conf.d/10-mail.conf':
  ensure => present,
}


exec{'mail location':
    cwd     => '/etc/dovecot/conf.d',
    command => 'sed -i s+^mail_location.*+"mail_location = maildir:/var/mail/vhosts/%d/%n"+g 10-mail.conf',
    path    => '/bin/',
    unless  =>'/bin/grep "maildir:/var/mail/vhosts/" 10-mail.conf'
  }

  exec{'mail privileged group':
    cwd     => '/etc/dovecot/conf.d',
    command => 'sed -i s+^mail_privileged_group.*+"mail_privileged_group = mail"+g 10-mail.conf',
    path    => '/bin/',
    unless  =>'/bin/grep "mail_privileged_group = mail" 10-mail.conf'
  }


file {'/etc/dovecot/conf.d/10-auth.conf':
  ensure => present,
}

exec{'block clear pwd':
    cwd     => '/etc/dovecot/conf.d',
    command => 'sed -i s+"\#\!include auth-sql.*"+"\!include auth-sql.conf.ext"+g 10-auth.conf',
    path    => '/bin/',
    unless  =>'/bin/grep "^\!include auth-sql.conf.ext$" 10-auth.conf'
  }

file {'/etc/dovecot/conf.d/auth-sql.conf.ext':
  ensure => present,
  source => '/vagrant/puppet/files/dovecot/auth-sql.conf.ext'
}

file {'/etc/dovecot/conf.d/dovecot-sql.conf.ext':
  ensure => present,
  source => '/vagrant/puppet/files/dovecot/dovecot-sql.conf.ext'
}

service {'dovecot':
  ensure => running,
  enable => true
}


### Amavis

package {'amavisd-new':
  ensure => present
}

file {'/etc/amavis/conf.d/15-content-filter-mode':
  ensure => present,
  source => 'vagrant/puppet/files/amavis/15-content-filter-mode'
}

service {'amavis':
  ensure => running,
  enable => true
}

### ClamAv

package {'clamav':
  ensure => present
}

package {'clamav-daemon':
  ensure => present
}


### Spamassassin

package {'spamassassin':
  ensure => present
}

file {'/etc/default/spamassassin':
  ensure => present,
  source => '/vagrant/puppet/files/spamassassin/spamassassin'
}



exec {'wget https://github.com/roundcube/roundcubemail/releases/download/1.5.1/roundcubemail-1.5.1.tar.gz':
  path    => '/usr/bin',
  cwd     => '/tmp/',
  creates => '/var/www/html/roundcubemail/index.php'
}

exec {'tar -xzf "roundcubemail-1.5.1.tar.gz"':
  path    => '/bin',
  cwd     => '/tmp/',
  creates => '/var/www/html/roundcubemail/index.php'
}

exec { 'sudo mv roundcubemail-1.5.1 /var/www/html/roundcubemail':
  path    => '/usr/bin',
  cwd     => '/tmp/',
  creates => '/var/www/html/roundcubemail/index.php'
}

file {['/var/www/html/roundcubemail/temp', '/var/www/html/roundcubemail/logs']:
  ensure => directory,
  owner  => 'www-data',
  mode   => '0755',
}

mysql::db { 'roundcubemail':
  user     => 'roundcubemail',
  password => 'roundcubemail',
  host     => 'localhost',
  grant    => ['ALL'],
  sql      => '/var/www/html/roundcubemail/SQL/mysql.initial.sql',
}

file {'/etc/apache2/sites-available/roundcube.conf':
  ensure => present,
  source => '/vagrant/puppet/files/roundcube/rc.conf'
}

file {'/etc/apache2/sites-available/roundcube-ssl.conf':
  ensure => present,
  source => '/vagrant/puppet/files/roundcube/rc-ssl.conf'
}

exec {'a2ensite roundcube.conf':
  path   => '/usr/sbin',
  cwd    => '/etc/apache2/sites-available',
  notify => Service['apache2']
}

exec {'a2ensite roundcube-ssl.conf':
  path   => '/usr/sbin',
  cwd    => '/etc/apache2/sites-available',
  notify => Service['apache2']
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
