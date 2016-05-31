# == Define: sssd::domain
#
define sssd::domain (
  $options,
) {
  include ::sssd

  concat::fragment{"sssd_conf-domain_list_${name}":
    target  => $::sssd::conf_path,
    content => " ${name},",
    order   => "05",
  }

  concat::fragment{"sssd_conf-domain_section_${name}":
    target  => $::sssd::conf_path,
    content => epp('sssd/domain.epp', {name => $name, options => $options}),
    order   => "20",
  }
}
