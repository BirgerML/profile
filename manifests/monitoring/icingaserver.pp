class profile::monitoring::icingaserver {
  $mysql_password = hiera('profile::monitoring::mysql_password')
  $icinga_db_password = hiera('profile::monitoring::icinga_db_password')
  $icingaweb2_db_password = hiera('profile::monitoring::icingaweb2_db_password')
  #$icingaadmin_password = hiera('profile::monitoring::icingaadmin_password')

  class { '::apache':
    mpm_module => 'prefork',
  }
  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php

  class { '::mysql::server':
    root_password => $mysql_password,
  } ->
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => $icinga_db_password,
    host     => 'localhost',
  }
  mysql::db { 'icingaweb2':
    user     => 'icingaweb2',
    password => $icingaweb2_db_password,
    host     => 'localhost',
  }
  
  class { '::icinga2::server':
    server_db_type                => 'mysql',
    db_host                       => 'localhost',
    db_port                       => '3306',
    db_name                       => 'icinga2_data',
    db_user                       => 'icinga2',
    db_password                   => $icinga_db_password,
    server_install_nagios_plugins => false,
    install_mail_utils_package    => false,
  }
  package { 'heirloom-mailx':
    ensure => latest,
  }
  icinga2::object::idomysqlconnection { 'mysql_connection':
    target_dir       => '/etc/icinga2/features-enabled',
    target_file_name => 'ido-mysql.conf',
    host             => '127.0.0.1',
    port             => '3306',
    user             => 'icinga2',
    password         => $icinga_db_password,
    database         => 'icinga2_data',
    categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement',
                         'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }
  icinga2::object::hostgroup { 'linux_servers': }
  Icinga2::Object::Host <<| |>>

  icinga2::object::apply_service_to_host { 'check_load':
    display_name   => 'Load from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_load',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_swap':
    display_name   => 'Swap from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_swap',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name   => 'Disk from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_disk',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }

  class {'::icingaweb2':
      admin_users         => 'data',
      ido_db_name         => 'icinga2_data',
      ido_db_pass         => $icinga_db_password,
      ido_db_user         => 'icinga2',
      manage_apache_vhost => true;
  }
}
