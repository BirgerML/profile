class profile::monitoring::logstashforwarder {

  $logstash_server = hiera('profile::monitorng::logstash_server')

  class { '::logstashforwarder':
    servers     => [ "${logstash_server}" ],
    ssl_ca      => 'puppet:///modules/profile/keys/logstash.crt',
    manage_repo => true,
    autoupgrade => true,
  }

  logstashforwarder::file { 'syslog':
    paths  => [ '/var/log/syslog', '/var/log/auth.log' ],
    fields => { 'type' => 'syslog' },
  }

}
