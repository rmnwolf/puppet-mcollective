# Class mcollective::client::config::securityprovider::psk
class mcollective::client::config::securityprovider::psk {
  mcollective::client::setting { 'securityprovider':
    value => 'psk',
  }

  mcollective::client::setting { 'plugin.psk':
    value => $mcollective::psk,
  }
}