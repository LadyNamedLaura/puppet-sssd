

# == Class: sssd
#
class sssd (
  $conf_path = '/etc/sssd/sssd.conf',
  $enable_nss = true,
  $enable_pam = true,
) {
  concat { $conf_path:
    ensure => present,
    mode   => '600',
    owner  => 'root'
  }

  package { 'sssd':
    ensure => installed,
  } ->
  service { 'sssd':
    ensure => running,
    enable => true,
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

  if $enable_nss {
    sssd::service {'nss':  }
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
  if $enable_pam {
    sssd::service{'pam':}
    pam {
      default:
        ensure    => present,
        service   => 'system-auth',
        module    => 'pam_sss.so',
      ;
      'Set sss entry to system-auth auth':
        type      => 'auth',
        control   => 'sufficient',
        arguments => 'use_first_pass',
        position  => 'before module pam_deny.so',
      ;
      'Set sss entry to system-auth session':
        type      => 'session',
        control   => 'sufficient',
        position  => 'before module pam_unix.so',
      ;
      'Set sss entry to system-auth password':
        type      => 'password',
        control   => 'sufficient',
        arguments => 'authtok',
        position  => 'before module pam_deny.so',
      ;
      'Set sss entry to system-auth account':
        type      => 'account',
        control   => '[default=bad success=ok user_unknown=ignore authinfo_unavail=ignore]',
        arguments => 'authtok',
        position  => 'before module pam_deny.so',
      ;
    }
  }

}
