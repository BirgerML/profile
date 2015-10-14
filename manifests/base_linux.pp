class profile::base_linux {

  $root_ssh_key = hiera('base_linux::root_ssh_key')
  $linux_sw_pkg = hiera('base_linux::linux_sw_pkg')

  class { 'ntp':
    servers  => [ 'npt.hig.no' ],
    restrict => [
      'default kod nomdify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }

  class { 'timezone':
    timezone => 'Europe/Oslo',
  }
  
  package { $linux_sw_pkg:
    ensure => latest,
  }

  file { '/root/.ssh/':
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    ensure => 'directory',
  }

  ssh_authorized_key { 'root@manager':
    user    => 'root',
    type    => 'ssh-rsa',
    key     => $root_ssh_key,
    require => File['/root/.ssh']
  }
  include ::profile::monitoring::logstashforwarder

  unless $::fqdn == 'monitor.borg.trek' {
    include ::profile::monitoring::icingaclient
  }
}
