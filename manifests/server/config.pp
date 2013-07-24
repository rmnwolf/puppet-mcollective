# private class
class mcollective::server::config {
  datacat { 'mcollective::server':
    path     => '/etc/mcollective/server.cfg',
    template => 'mcollective/settings.cfg.erb',
  }

  mcollective::server::setting { 'daemonize':
    value => $mcollective::server_daemonize,
  }

  file { '/etc/mcollective/policies':
    ensure => 'directory',
  }

  file { '/etc/mcollective/clients':
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    mode    => '0444',
    source  => $mcollective::ssl_client_certs,
  }

  $connector_class = "mcollective::server::config::connector::${mcollective::connector}"
  if defined($connector_class) {
    class { "mcollective::server::config::connector::${mcollective::connector}":
      requre => Anchor['mcollective::server::config::begin'],
      before => Anchor['mcollective::server::config::end'],
    }
  }

  anchor { 'mcollective::server::config::begin': } ->
  class { "mcollective::server::config::securityprovider::${mcollective::securityprovider}": } ->
  class { "mcollective::server::config::factsource::${mcollective::factsource}": } ->
  class { "mcollective::server::config::rpcauditprovider::${mcollective::rpcauditprovider}": } ->
  class { "mcollective::server::config::rpcauthprovider::${mcollective::rpcauthprovider}": } ->
  anchor { 'mcollective::server::config::end': }
}
