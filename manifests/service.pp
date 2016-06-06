# == Class: sssd::service
#
define sssd::service(
  Hash[String,String] $options = {},
) {
  include ::sssd

  concat::fragment{"sssd_conf-service_list_${name}":
    target  => $::sssd::conf_path,
    content => " ${name},",
    order   => "03",
  }

  concat::fragment{"sssd_conf-service_section_${name}":
    target  => $::sssd::conf_path,
    content => epp('sssd/service.epp', {name => $name, options => $options}),
    order   => "10",
  }
}
