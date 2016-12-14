# Class: tesora_cyclone::params
#
# This class holds parameters that need to be
# accessed by other classes.
class tesora_cyclone::params {
  case $::osfamily {
    'RedHat': {
      $packages = ['parted', 'puppet', 'wget', 'iputils']
      $user_packages = ['emacs-nox', 'vim-enhanced']
      $update_pkg_list_cmd = ''
      $login_defs = 'puppet:///modules/tesora_cyclone/login.defs.redhat'
    }
    'Debian': {
      $packages = ['parted', 'puppet', 'wget', 'iputils-ping']
      case $::operatingsystemrelease {
        /^(12|14)\.(04|10)$/: {
          $user_packages = ['emacs23-nox', 'vim-nox', 'iftop',
                            'sysstat', 'iotop']
        }
        default: {
          $user_packages = ['emacs-nox', 'vim-nox']
        }
      }
      $update_pkg_list_cmd = 'apt-get update >/dev/null 2>&1;'
      $login_defs = 'puppet:///modules/tesora_cyclone/login.defs.debian'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'tesora_cyclone' module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
