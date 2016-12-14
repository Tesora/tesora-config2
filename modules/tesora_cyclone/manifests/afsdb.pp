# AFS DB Server
class tesora_cyclone::afsdb (
) {

  class { '::tesora_cyclone::afsfs': }

  class { '::openafs::dbserver':
    require => Class['Openstack_project::Afsfs'],
  }

}
