class profile::monitoring::icingaclient {
  $management_if = hiera("profile::interfaces::management")
  $management_ip = getvar("::ipaddress_${management_if}")

  @@icinga2::object::host { $::fqdn:
    display_name     => $::fqdn,
    ipv4_address     => $management_ip,
    groups           => [['linux_servers',],],
    vars             => {
                          os           => 'linux',
                          distro       => $::operatingsystem,
                        },
    target_dir       => '/etc/icinga2/objects/hosts',
    target_file_name => "${::fqdn}.conf",
  }
  class { '::icinga2::nrpe':
    nrpe_allowed_hosts => ['172.17.1.12','127.0.0.1'],
  }
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 15,10,5 -c 25,20,15',
  }
  icinga2::nrpe::command { 'check_swap':
    nrpe_plugin_name => 'check_swap',
    nrpe_plugin_args => '-w 90% -c 50%',
  }
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 50% -c 20%',
  }
}
