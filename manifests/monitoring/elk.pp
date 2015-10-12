class profile::monitoring::elk {
  $logstash_key = hiera('profile::monitoring::logstash_key')

  class { '::elasticsearch':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.6',
    java_install => true,
  }
  elasticsearch::instance { 'es-01': }

  file { [ '/etc/pki/', '/etc/pki/tls/', '/etc/pki/tls/certs/', '/etc/pki/tls/private/' ]:
    ensure => directory,
  } ->
  file { '/etc/pki/tls/private/logstash.key':
    ensure  => file,
    content => "${logstash_key}",
  } ->
  file { '/etc/pki/tls/certs/logstash.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/logstash.crt',
  } ->
  class { '::logstash':
    autoupgrade  => true,
    manage_repo  => true,
    repo_version => '1.5',
    java_install => true,
  }

  logstash::configfile { 'logstash-logs.conf':
    source => 'puppet:///modules/profile/logstash-logs.conf',
  }
  
#  logstash::patternfile { 'openstack-patterns':
#    source => 'puppet:///modules/profile/openstack-patterns',
#  }

  class { '::kibana': }

}

