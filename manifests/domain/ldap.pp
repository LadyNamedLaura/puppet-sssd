# == Define: sssd::domain::ldap
#
define sssd::domain::ldap (
  $uri,
  $search_base,
  $authtok_type    = undef,
  $authtok         = undef,
  $bind_dn         = undef,
  $schema          = 'rfc2307',
  $start_tls       = true,
  $tls_reqcert     = 'demand',
  $tls_cacert      = undef,
  $chpass          = false,
  $network_timeout = 2,
  $cache_timeout   = 600,
  $extra_options   = {},
) {

  $options = {
    id_provider               => 'ldap',
    auth_provider             => 'ldap',
    chpass_provider           => 'ldap',
    cache_credentials         => true,
    entry_cache_timeout       => $cache_timeout,
    ldap_uri                  => $uri,
    ldap_schame               => $schema,
    ldap_search_base          => $search_base,
    ldap_id_use_start_tls     => $start_tls,
    ldap_tls_reqcert          => $tls_reqcert,
    ldap_tls_cacert           => $tls_cacert,
    ldap_default_authtok_type => $authtok_type,
    ldap_default_authtok      => $authtok,
    ldap_default_bind_dn      => $bind_dn,
    ldap_network_timeout      => $network_timeout,
  }
  sssd::domain{$name:
    options => merge($options,$extra_otions)
  }
}
