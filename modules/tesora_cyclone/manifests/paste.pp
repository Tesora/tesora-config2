# == Class: tesora_cyclone::paste
#
class tesora_cyclone::paste (
  $db_password,
  $db_host,
  $vhost_name         = $::fqdn,
) {
  include lodgeit
  lodgeit::site { 'openstack':
    port        => '5000',
    db_password => $db_password,
    db_host     => $db_host,
    db_user     => 'openstack',
    vhost_name  => $vhost_name,
    image       => 'header-bg2.png',
  }
}
