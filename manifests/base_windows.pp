class profile::base_windows {

  $win_sw_pkg = hiera('base_windows::win_sw_pkg')

  exec { 'chocoInstall':
    command => 'iex ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))',
    unless => 'if (!(Test-Path "C:\ProgramData\chocolatey\choco.exe")) { exit 1}',
    provider => powershell,
  }

  case $::operatingsystem {
    'windows':
      { Package { provider => chocolatey, require => Exec['chocoInstall'], } }
  }

  package { $win_sw_pkg:
    ensure => 'latest',
  }

  dsc::lcm_config { 'disable_lcm':
    refresh_mode => 'Disabled',
    before       => Dsc_xtimezone['Oslo'],
  }

  dsc_xtimezone { 'Oslo':
    dsc_timezone         => 'W. Europe Standard Tome',
    dsc_issingleinstance => 'yes',
  }

}
