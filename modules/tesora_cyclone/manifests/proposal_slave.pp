# Slave used for automatically proposing changes to Gerrit,
# Transifex and other tools.
#
# == Class: tesora_cyclone::translation_slave
#
class tesora_cyclone::proposal_slave (
  $jenkins_ssh_public_key,
  $proposal_ssh_public_key,
  $proposal_ssh_private_key,
  $jenkins_gitfullname = 'OpenStack Jenkins',
  $jenkins_gitemail = 'jenkins@openstack.org',
  $project_config_repo = 'https://git.openstack.org/openstack-infra/project-config',
  $zanata_server_url,
  $zanata_server_user,
  $zanata_server_api_key,
) {

  class { '::zanata::client':
    server_url     => $zanata_server_url,
    server_user    => $zanata_server_user,
    server_api_key => $zanata_server_api_key,
  }

  class { 'tesora_cyclone::slave':
    ssh_key             => $jenkins_ssh_public_key,
    jenkins_gitfullname => $jenkins_gitfullname,
    jenkins_gitemail    => $jenkins_gitemail,
    project_config_repo => $project_config_repo,
  }

  package { ['Babel', 'pyopenssl', 'ndg-httpsclient', 'pyasn1',
             'pyyaml', 'requestsexceptions']:
    ensure   => latest,
    provider => openstack_pip,
    require  => Class['pip'],
  }

  file { '/home/jenkins/.ssh/id_rsa':
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    require => File['/home/jenkins/.ssh'],
    content => $proposal_ssh_private_key,
  }

  file { '/home/jenkins/.ssh/id_rsa.pub':
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    require => File['/home/jenkins/.ssh'],
    content => $proposal_ssh_public_key,
  }
}
