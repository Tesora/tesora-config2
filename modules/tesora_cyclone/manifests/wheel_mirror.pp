# == Class: tesora_cyclone::wheel_mirror
#
class tesora_cyclone::wheel_mirror (
  $data_directory = '/srv/static/wheel',
  $config_directory = '/etc/wheel_mirror'
) {

  # The wheel mirror is a directory of python wheels, which have been rsynced'
  # from the wheel build slaves.
  file { "${data_directory}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
  }

  file { "${config_directory}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
  }

  file { "${config_directory}/rebuild_wheel_afs_index.sh":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source => "puppet:///modules/tesora_cyclone/mirror/rebuild_wheel_afs_index.sh",
    require => [
      File["${config_directory}"],
    ]
  }

  # */15 * * * *
  cron { 'rebuild wheel afs index':
    name    => 'rebuild-wheel-afs-index.cron',
    command => "/bin/bash ${config_directory}/rebuild_wheel_afs_index.sh ${data_directory}",
    user    => root,
    minute  => '*/15',
    require => [
      File["${config_directory}/rebuild_wheel_afs_index.sh"],
    ]
  }
}
