# == Class: tesora_cyclone::infracloud::base
#
# A template host with no running services
#
class tesora_cyclone::infracloud::base (
) {
  class { '::unbound':
    install_resolv_conf => true,
  }
}
