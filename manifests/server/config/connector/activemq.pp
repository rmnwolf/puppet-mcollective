# private class
class mcollective::server::config::connector::activemq {
  mcollective::server::setting { 'connector':
    value => 'activemq',
  }

  mcollective::server::setting { 'direct_addressing':
    value => 1,
  }

  mcollective::server::setting { 'plugin.activemq.pool.size':
    value => size($mcollective::middleware_hosts),
  }

  # Oh puppet!  Fake iteration of the indexes (+1 as plugin.activemq.pool is
  # 1-based)
  $indexes = range('1', size($mcollective::middleware_hosts))
  mcollective::server::config::connector::activemq::hosts_iteration { $indexes: }
}
