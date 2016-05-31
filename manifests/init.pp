

# == Class: sssd
#
class sssd (
  $conf_path = '/tmp/sssd.conf',
  $default_services = ['nss','pam']
) {
  concat { $conf_path:
    ensure => present,
  }

  ## order:
  # 0* => [sssd]
  #   01 => main
  #   02 => "services ="
  #   03 => "${servicename},"
  #   04 => "domains ="
  #   05 => "${domainname},"
  # 1* => services
  # 2* => domains

  concat::fragment {
    default:
      target  => $conf_path,
      ;
    'ssd_conf-Head':
      content => "[sssd]\nconfig_file_version=2\n",
      order   => '01',
      ;
    'ssd_conf-services':
      content => "\nservices =",
      order   => '02'
      ;
    'ssd_conf-domains':
      content => "\ndomains =",
      order   => '04'
      ;
    'ssd_conf-end_head':
      content => "\n\n",
      order   => '09',
  }

  sssd::service { $default_services:  }
  nsswitch::entry {
    default:
      value => 'sss',
      order => '60',
      ;
    "sssd_passwd":
      database => 'passwd';
    "sssd_shadow":
      database => 'shadow';
    "sssd_group":
      database => 'group';
    "sssd_netgroup":
      database => 'netgroup';
    "sssd_automount":
      database => 'automount';
  }

}
