# == Class: tesora_cyclone::reprepro_mirror
#
class tesora_cyclone::reprepro_mirror {
  package { 'reprepro':
    ensure => present,
  }

  file { '/var/log/reprepro':
    ensure => directory,
  }

  file { '/var/run/reprepro':
    ensure => directory,
  }

  file { '/etc/reprepro':
    ensure => directory,
  }

  cron { 'reprepro':
    ensure => absent,
  }
}
