node default {
  include mysql::server

file {'/srv/postfixadmin/templates_c':
  ensure => directory,
  owner  => 'www-data',
  mode   => '0755'
}

file {'/srv/postfixadmin/config.local.php':
  ensure => present,
}

}

