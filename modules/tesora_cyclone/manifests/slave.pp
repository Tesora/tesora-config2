# == Class: tesora_cyclone::slave
#
class tesora_cyclone::slave (
  $thin = false,
  $certname = $::fqdn,
  $ssh_key = '',
  $sysadmins = [],
  $jenkins_gitfullname = 'OpenStack Jenkins',
  $jenkins_gitemail = 'jenkins@openstack.org',
  $jenkins_gitpgpkey = 'jenkins@openstack.org',
  $jenkins_gerrituser = 'jenkins',
  $jenkins_gerritkey = undef,
  $project_config_repo = 'https://git.openstack.org/openstack-infra/project-config',
  $afs = false,
) {

  include tesora_cyclone
  include tesora_cyclone::tmpcleanup

  class { 'tesora_cyclone::server':
    iptables_public_tcp_ports => [19885],
    iptables_public_udp_ports => [],
    certname                  => $certname,
    sysadmins                 => $sysadmins,
    afs                       => $afs
  }

  class { 'jenkins::slave':
    ssh_key      => $ssh_key,
    gitfullname  => $jenkins_gitfullname,
    gitemail     => $jenkins_gitemail,
    gitpgpkey    => $jenkins_gitpgpkey,
    gerrituser   => $jenkins_gerrituser,
    gerritkey    => $jenkins_gerritkey,
  }

  include jenkins::cgroups
  include ulimit
  ulimit::conf { 'limit_jenkins_procs':
    limit_domain => 'jenkins',
    limit_type   => 'hard',
    limit_item   => 'nproc',
    limit_value  => '256'
  }

  class { 'tesora_cyclone::slave_common':
    project_config_repo => $project_config_repo,
  }

  if (! $thin) {
    include tesora_cyclone::thick_slave
  }

}
